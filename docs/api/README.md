# Zeus OS REST API reference (OpenAPI)

The API is described by an OpenAPI 3.0.3 document, served live at `GET /api/v1/openapi.json` (Swagger UI at
`/api/v1/docs`) and checked in as [`docs/openapi.json`](../openapi.json). The typed Python and Go SDKs
([`sdk/README.md`](../../sdk/README.md)) are generated from that file.

## How trustworthy is a schema?

Nothing in the spec is hand-typed from memory. The bulk of it is **derived from the server's own code**:

* the route table (`.route("/path", get(h).post(h2))` registrations under `web/src/`),
* each handler's signature: `Path<..>`, `Query<T>`, `Json<T>` request bodies, `Result<Json<T>, _>` / `Json<T>` responses,
* the serde definition of every referenced struct/enum (`rename`, `rename_all`, `default`, `skip_serializing_if`,
  `flatten`, untagged enums, generics such as `PaginatedResponse<T>`).

Every operation says how deep that goes in `x-zeus-schema`:

| `x-zeus-schema` | Meaning |
|---|---|
| `typed` | a request and/or response schema was derived from Rust types |
| `untyped` | the handler was analysed but its body is `serde_json::Value` (free-form JSON) or unknown |
| `none` | the handler could not be resolved (e.g. a closure): method and path only |
| `curated` | hand-written operation (only for routes with no derived operation) |

Other extensions: `x-zeus-role` (minimum role the handler itself enforces: `authenticated`, `editor`, `admin`) and
`x-zeus-source` (handler that produced the operation). Independently of `x-zeus-role`, **viewers are denied every
POST/PUT/PATCH/DELETE**, and namespaced resources are filtered by tenant.

Known limits, so you do not over-trust the spec:

* A success response that a handler builds with `json!({...})` is `untyped`; the field list is not inferred.
* `(StatusCode, Json<T>)` returns are documented as `2XX` (the exact code is not knowable from the type).
* Types that live outside this repository (Kubernetes objects, ...) are free-form JSON with a description saying so.
* An `Option<T>` field is `nullable` and *not* `required` (Rust may emit `null`, or omit it via `skip_serializing_if`).
* Enums with data-carrying variants are free-form; untagged enums of newtype variants become `oneOf`.
* Routes registered per auth mode (`/auth/login`) document the union; see the operation description.
* WebSocket routes (`/ws/...`) are not REST and are not in the spec. `/health` and `/ready` live at the server root
  and carry a path-level `servers` override.

## Authentication in the spec

Three security schemes, all carrying the same token: `bearerAuth` (`Authorization: Bearer <token>`, preferred),
`cookieAuth` (`zeus_os_token` cookie) and `queryToken` (`?zeus_os_token=`, for iframe embeds; URLs get logged).
A token is a session token from login/OIDC/SAML, a per-user API token (`v9s_...`) or the deployment
`ZEUS_OS_API_KEY`. Public endpoints (`/auth/config`, the login endpoints, `/health`, `/ready`) declare `security: []`.
Every other operation lists a `401` response; errors are `{"error": "<message>"}` (`components/schemas/Error`).

## Layers and files

| Layer | File | Edited by |
|---|---|---|
| Derived operations + schemas | `web/src/routes/openapi/generated.json` | `python3 scripts/gen-openapi-paths.py --update` (never by hand) |
| Curated summaries/tags | `web/src/routes/openapi/curated.rs` | by hand; only for real routes (unit test enforces it) |
| Auth/health overlays | `web/src/routes/openapi/overlays.rs` | by hand; replaces derived bodies/responses |
| Assembly + tests | `web/src/routes/openapi.rs` | by hand |
| Served/checked-in rendering | `docs/openapi.json` | `ZEUS_OS_WRITE_OPENAPI=1 cargo test -p zeus-os-web --bins openapi_json_matches_checked_in_docs` |
| Route inventory + coverage | `docs/openapi-paths.json`, `scripts/openapi-coverage-baseline.json` | `python3 scripts/gen-openapi-paths.py [--update]` |

Curated entries only fill gaps: a curated summary/description/tag wins, but a curated generic
`{"type":"object"}` body never replaces a derived typed schema.

## Regenerating after you add or change a route

```bash
python3 scripts/gen-openapi-paths.py --update     # 1. re-derive generated.json, refresh baseline + route inventory
ZEUS_OS_WRITE_OPENAPI=1 cargo test -p zeus-os-web --bins openapi_json_matches_checked_in_docs   # 2. docs/openapi.json
python3 scripts/gen-sdks.py                       # 3. SDKs
python3 scripts/gen-openapi-paths.py --check && python3 scripts/gen-sdks.py --check   # verify (CI)
cargo test -p zeus-os-web --bins openapi          # spec validity tests
```

`--check` fails if documented/typed coverage fell below `scripts/openapi-coverage-baseline.json` or if
`generated.json` is stale relative to the Rust sources. The `openapi` Rust tests fail if `docs/openapi.json` is stale.

If a handler you add is `untyped`, give it a concrete `Json<YourStruct>` return type (with `Serialize`) rather than
`Json<Value>`; that is the whole trick to a typed spec and typed SDKs.

## What the Rust tests check

`cargo test -p zeus-os-web --bins openapi` validates the served document: OpenAPI 3.0.3 structure, every `$ref`
resolves, every `{param}` in a path is declared as a required path parameter (and no undeclared ones), every
`operationId` is a unique identifier, no two paths are equivalent templates, every status key is valid, every security
requirement names a defined scheme, every curated overlay describes a real route, and `docs/openapi.json` equals the
served spec.

## Using the API directly

```bash
TOKEN=$(curl -s -X POST http://localhost:5050/api/v1/auth/login -H 'content-type: application/json' \
  -d '{"username":"admin","password":"..."}' | jq -r .token)
curl -s -H "Authorization: Bearer $TOKEN" 'http://localhost:5050/api/v1/vms?page=1&per_page=20'
curl -s -X POST -H "Authorization: Bearer $TOKEN" http://localhost:5050/api/v1/vms/prod/web-1/start
```

Generate a client in another language with any OpenAPI 3.0 generator pointed at `docs/openapi.json`; operation ids are
snake_case handler names (they change only if a handler is renamed).
