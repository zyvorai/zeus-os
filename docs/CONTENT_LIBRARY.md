# Content library: signed template bundles between Zeus instances

The content library moves VM templates from one Zeus instance to another as a
single signed JSON file (a *bundle*). It is opt-in, additive and conservative:
nothing is ever auto-approved, nothing existing is overwritten, and a bundle is
only accepted when it is signed by a key you have chosen to trust.

Existing git sync (`POST /templates/sync-git`) is unchanged and independent.

## What a bundle contains

```json
{
  "format_version": 1,
  "kind": "zeus-template-bundle",
  "bundle_id": "bundle-<uuid>",
  "created_at": "2026-09-25T12:00:00+00:00",
  "source_instance": { "id": "<key id>", "name": "lab-a" },
  "templates": [
    {
      "name": "web-base", "display_name": "...", "description": "...",
      "category": "linux", "os_type": "linux", "version": "1.2.0",
      "tags": [], "quick_deploy": false,
      "spec": { "...": "cpu, memory, disk, cloud_init, ..." },
      "parameters": [],
      "source_status": "approved",
      "executable_content": ["spec.cloud_init"],
      "omitted_fields": ["spec.storage_class"],
      "sha256": "<hex sha-256 of this template's canonical JSON>"
    }
  ],
  "signature": { "alg": "ed25519", "key_id": "...", "public_key": "<base64>", "value": "<base64>" }
}
```

* `executable_content` flags the members that run code inside a guest. Today
  that is `spec.cloud_init`. The importer recomputes it and never trusts the flag.
* Instance-local references are stripped on export and listed in
  `omitted_fields`: `spec.golden_datavolume`, `spec.storage_class`, and the
  default value of any `secret` parameter. Storage class names inside
  `additional_disks` and network attachment names are kept but are **not**
  verified against the importing cluster; they may need editing after import.
* Only ConfigMap-backed templates are exported (the same ones `GET /templates`
  shows as `source: configmap`). Built-in and golden templates are not.

## Trust model (read this)

Signatures use **Ed25519**, so verification needs only a public key.

* Each instance generates a signing key on first use and stores it in
  `$ZEUS_OS_DATA_DIR/template-library-signing-key.json` with mode `0600`. It
  is never returned by the API or logged. If the file exists but is unreadable
  the export fails; the key is never silently regenerated (that would change
  the instance's identity and break every peer that pinned it). **Back this
  file up** along with the rest of the data dir; losing it means peers must
  re-pin a new key.
* `GET /templates/library/key` returns the public key and its key id
  (first 16 hex characters of the SHA-256 of the raw key).
* A signature only proves the bundle was made by *some* key. It is accepted
  only if that key is one of:
  1. this instance's own key (lets you re-import your own bundle),
  2. a key pinned by a visible **subscription**,
  3. a key listed in `ZEUS_OS_LIBRARY_TRUSTED_KEYS` (comma separated
     `<base64>` or `<label>=<base64>`).

  An unsigned bundle, a bundle signed by an unknown key, or a bundle that
  embeds a different key than the one you trust is rejected. The embedded
  `signature.public_key` is never trusted on its own.
* When you import *from a subscription*, only that subscription's pinned key is
  accepted, not the wider trust set.
* **Key pinning at subscribe time.** `POST /templates/library/subscribe` takes
  an optional `public_key`. If you supply it, that is what gets pinned. If you
  omit it the server fetches `/templates/library/key` from the remote once and
  pins the result (trust on first use). The response then carries a warning and
  the fingerprint: confirm it with the remote operator over another channel.
  Anyone able to intercept that first fetch could substitute their own key, so
  prefer supplying the key when the channel is not fully trusted.
* Verification does not protect against a *trusted* peer that ships bad
  content. That is why imports are drafts (below).

What is covered by the signature: the canonical serialisation (keys sorted,
`4.0` and `4` equal, no insignificant whitespace) of the whole manifest minus
the `signature` member. Changing any template, hash, `bundle_id`, timestamp or
source name invalidates it. Each template also carries its own SHA-256, checked
as a second layer.

## Import policy

`POST /templates/library/import` (Editor or Admin):

| Rule | Behaviour |
|------|-----------|
| Status | Every imported template is `draft`, whatever `source_status` says. Approving is a separate, normal step. Drafts cannot be deployed to production namespaces, and elsewhere only when `ZEUS_OS_ALLOW_DRAFT_TEMPLATES=1`. |
| Ownership | Created as ConfigMaps in the `namespace` you name (default `default`); tenant scope is enforced with the same namespace check as `POST /templates`. The namespace must already exist. |
| Overwrite | Never. A name that exists in the target namespace, or that matches a built-in template (a same-named ConfigMap would shadow it), is **skipped** (`on_conflict: "skip"`, the default) or imported as `<name>-imported`, `-imported-2`, ... (`"rename"`). Creation uses Kubernetes create, so a race also cannot overwrite. |
| Validation | Each template goes through `build_configmap_from_save`, the same code as `POST /templates` (cloud-init security scan, denylist, 128 KiB cloud-init cap), plus DNS-label names, label-safe `category`/`os_type`/`tags`, and numeric bounds (1-512 vCPU, memory up to 4096 GiB, disk up to 64 TiB). Invalid entries are reported and skipped; the rest still import. |
| Caps | 4 MiB per bundle, 512 KiB per template, 200 templates, 50 subscriptions. Fetches stop reading at the cap. |
| Executable content | A real import of any template with cloud-init requires `"acknowledge_executable_content": true`, otherwise the request is refused with 400. Dry-run does not require it. |
| Dry run | `"dry_run": true` verifies everything and returns the per-template plan without creating anything. |
| Audit | Every export, subscribe, unsubscribe and real import is written to the remediation audit (`template_library.*`), including rejected bundles (bad signature, unknown signer, failed fetch). |

Imported ConfigMaps carry the labels/annotations `zeus-os.io/imported=true`,
`zeus-os.io/library-bundle-id`, `-source-instance`, `-signer-key-id`,
`-content-sha256`, `-source-name`, `zeus-os.io/imported-by`,
`zeus-os.io/imported-at`, and `zeus-os.io/author: library-import`.

## API

All under `/api/v1`.

| Method and path | Role | Purpose |
|-----------------|------|---------|
| `GET /templates/library` | any authenticated user | Signed bundle of the templates the caller can see. Query: `namespace`, `status`, `names` (comma separated). Tenant scope is the same as `GET /templates`. |
| `GET /templates/library/key` | any authenticated user | `{algorithm, key_id, public_key, format_version, instance_name}` |
| `GET /templates/library/subscriptions` | any authenticated user | Subscriptions visible to the caller's tenant. Tokens are never returned (`has_token` only). |
| `POST /templates/library/subscribe` | Admin | `{name, url, token?, public_key?}` |
| `DELETE /templates/library/subscriptions/{id}` | Admin | Removes the subscription and its pinned key (owner tenant enforced). |
| `POST /templates/library/import` | Editor+ | `{namespace, bundle \| subscription_id, dry_run, on_conflict, acknowledge_executable_content}` |

A template literally named `key` in a namespace named `library` is shadowed on
`GET /templates/library/key` by the static route; use another name.

## Outbound fetch and SSRF guard

Subscriptions are fetched by the server, so the URL is treated as hostile.
The rules match the plugin registry:

* `https` only, unless `ZEUS_OS_LIBRARY_ALLOW_HTTP=1`.
* No credentials in the URL, no query string or fragment on the base URL.
* Loopback, private, link-local (including `169.254.169.254`), CGNAT,
  unique-local and multicast addresses, single-label hosts and
  `.local`/`.internal`/`.svc`/`.cluster.local`/`.lan` names are refused unless
  the exact host is listed in `ZEUS_OS_LIBRARY_ALLOW_PRIVATE_HOSTS`
  (comma separated).
* The hostname is resolved by the server, every address is checked, and the
  connection is pinned to the checked addresses (defeats DNS rebinding).
* Redirects are not followed. 15 second timeout. Body capped while streaming.

The subscription bearer token is stored in
`$ZEUS_OS_DATA_DIR/template-library-subscriptions.json` (mode `0600`) in clear
text, like other integration credentials in the JSON stores. Use a token with
the least privilege that can read templates on the remote.

Subscriptions are tenant-scoped through `owner_tenant`: a subscription created
by a tenant-scoped admin is visible (and its key trusted) only for that tenant;
one created by a platform admin is shared.

## Environment variables

| Variable | Purpose |
|----------|---------|
| `ZEUS_OS_LIBRARY_ALLOW_HTTP` | `1` allows plain `http://` subscription URLs (default off). |
| `ZEUS_OS_LIBRARY_ALLOW_PRIVATE_HOSTS` | Exact hosts exempt from the internal-address block. |
| `ZEUS_OS_LIBRARY_TRUSTED_KEYS` | Extra trusted public keys (`<base64>` or `<label>=<base64>`), for uploaded bundles from instances you do not subscribe to. |
| `ZEUS_OS_INSTANCE_NAME` | Human-readable name put in `source_instance.name` (default `zeus-os`). |

## UI

Templates, then **Content library**: download a signed bundle, import from a
file or a subscription, and manage subscriptions (admins). An import is always
previewed first. When any template carries cloud-init the sheet shows a warning
and the confirm button stays disabled until the acknowledgement box is ticked.

## Known limits

* The template list caches ConfigMaps for 30 seconds, so an import can take up
  to that long to appear in `GET /templates`.
* There is no bundle revocation or key rotation flow. To rotate, delete the
  key file on the exporter (a new key is generated on next use) and re-pin it
  on every peer.
* Version numbers inside a bundle are informational; there is no dependency
  resolution between templates.
