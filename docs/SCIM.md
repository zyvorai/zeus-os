# SCIM 2.0 provisioning

Zeus OS exposes a SCIM 2.0 (RFC 7643 / RFC 7644) server so an identity provider can create, update, deactivate
and delete users and groups. It is mounted at **`/scim/v2`** (not under `/api/v1`) and is **disabled by
default**: every path answers `404` until it is configured.

Implementation: `web/src/scim.rs` (protocol and semantics), `web/src/routes/scim.rs` (HTTP layer and bearer
middleware), storage in the local auth user store (`ZEUS_OS_LOCAL_USERS_FILE`) plus `scim-groups.json` in
`ZEUS_OS_DATA_DIR`.

## Enabling

| Variable | Purpose |
|----------|---------|
| `ZEUS_OS_SCIM_TOKEN` | Static provisioning bearer token. **Minimum 32 characters**; a shorter value is rejected (SCIM stays disabled and an error is logged). Generate one with `openssl rand -hex 32`. |
| `ZEUS_OS_SCIM_API_TOKEN_AUTH` | `1`/`true`: also accept a Zeus API token (`v9s_...`) that belongs to an **admin** and carries the **`admin`** scope. Off by default. |
| `ZEUS_OS_SCIM` | `off` disables SCIM even if a token is configured (kill-switch). |
| `ZEUS_OS_SCIM_GROUP_ADMIN` | Comma-separated group `displayName`s that grant the platform-wide `admin` role. **Empty by default**: no group grants admin unless you list it here. |
| `ZEUS_OS_SCIM_GROUP_EDITOR` | Group names granting `editor` (default `zeus-os-editors`). |
| `ZEUS_OS_SCIM_GROUP_VIEWER` | Group names granting `viewer` (default `zeus-os-viewers`). |
| `ZEUS_OS_SCIM_TENANT_GROUP_PREFIX` | Prefix of tenant groups (default `zeus-os-tenant-`). |

The SCIM base URL is `https://<zeus-host>/scim/v2`.

### Authentication

Every request needs `Authorization: Bearer <token>`. SCIM has its **own** middleware and never accepts a
normal Zeus user session (Authorization header, cookie, query string or WebSocket sub-protocol): a valid admin
session gets `401`. The static token is compared in constant time (SHA-256 digests). Responses:
`404` = SCIM not enabled, `401` = missing/wrong token, `403` = an API token that is not an admin token with the
`admin` scope.

The token is a powerful credential: whoever holds it can create users and place them in groups. Treat it like an
admin password, rotate it by changing the environment variable and restarting, and prefer a network policy
that only allows your IdP to reach `/scim/v2`. If you list a group in `ZEUS_OS_SCIM_GROUP_ADMIN`, the token
holder can create platform admins by adding a user to that group; only do so deliberately.

## What is (and is not) provisioned

* SCIM manages **local accounts** in the Zeus user store. Only accounts **created through SCIM** are visible
  to or modifiable by SCIM. The built-in break-glass `admin` and any user created manually (Settings or
  `/api/v1/auth/users`) are unreachable: they are not listed, `GET/PUT/PATCH/DELETE /Users/{id}` returns
  `404` for them, they cannot be group members, and their user names are reserved. Creating a SCIM user whose
  `userName` matches an existing account (case-insensitively) returns `409`; `admin`, `api_key` and `dev` return
  `403`.
* **Passwords are never accepted or returned.** A `password` attribute (POST/PUT/PATCH) is rejected with
  `400 invalidValue`. `changePassword` is reported as unsupported. A provisioned user has no local password, so
  local login (`/auth/login`) fails for them; an administrator can still set a local password with the existing
  user-management API, after which they can log in locally as well. Sign-in for SCIM users is intended to be via
  your SSO.
* **JIT users are out of scope.** Users that OIDC/SAML/LDAP create on first login are not SCIM users and are not
  affected. Note that, in this release, SSO session creation does not consult the SCIM `active` flag: SCIM
  deactivation revokes the user's existing Zeus sessions, OIDC sessions and API tokens (by user name) and blocks
  local login, but an IdP-side deactivation is what stops new SSO logins. A helper
  (`local_auth::is_scim_deactivated`) exists for wiring a deny check into the SSO login paths.
* A newly provisioned user is a **`viewer`** until a mapped group says otherwise.

### Users

Supported attributes: `userName` (1-128 ASCII characters: letters, digits, `_ - . @ +`, starting with a letter or
digit; e-mail style names are fine), `externalId`, `displayName`, `name.givenName`, `name.familyName`, `emails`
(**one** address is stored: the `primary` one, else the first), `active`. `groups` is read-only. Other core
attributes (for example `phoneNumbers`, `title`, `roles`) and the enterprise extension are accepted and ignored.
`roles` are ignored on purpose: access comes only from groups. Some IdPs send booleans as the strings `"True"` /
`"False"`; both forms are accepted.

`active: false` (via PUT or PATCH):

1. marks the user inactive (local login refused),
2. revokes all their Zeus sessions and OIDC sessions,
3. revokes their API tokens.

`DELETE` removes the user, removes them from all groups and revokes the same credentials. A `PUT` that omits
`active` leaves it unchanged (it cannot silently re-enable a deactivated user). Renaming (`userName` change)
revokes the credentials issued under the old name.

### Groups and role / tenant mapping

Groups are stored by Zeus; membership is by SCIM user id. A group's `displayName` (case-insensitive, exact
match) decides what it grants:

| `displayName` | Effect |
|---------------|--------|
| listed in `ZEUS_OS_SCIM_GROUP_ADMIN` | member gets the `admin` role. As for local admins this is **platform-wide** (no tenant list). Nothing is listed by default. |
| listed in `ZEUS_OS_SCIM_GROUP_EDITOR` (default `zeus-os-editors`) | `editor` |
| listed in `ZEUS_OS_SCIM_GROUP_VIEWER` (default `zeus-os-viewers`) | `viewer` |
| `<prefix><tenant-id>` (default `zeus-os-tenant-acme`) | member belongs to tenant `acme` (namespace label `zeus-os.io/tenant`). `<tenant-id>` must be 1-63 characters of `A-Z a-z 0-9 - _ .` |
| anything else | stored, but grants nothing |

A user's effective role is the **highest** role among their groups (default `viewer`); tenants are the union of
their tenant groups. A non-admin with no tenant group keeps the default scope (a tenant named after their user
name). Whenever membership, a group name, or the mapping changes, the access of every SCIM-managed user is
recomputed on the next SCIM write; users whose role/tenants changed have their sessions revoked (a session is a
snapshot of the old role) and an audit entry is written. Deleting a group demotes its members accordingly.
Nested groups are not supported; group `members` must be SCIM user ids that exist.

### Filtering, pagination, PATCH

* `GET /Users` and `GET /Groups` accept `filter`, `startIndex` (1-based), `count` (default 100, max 200;
  `count=0` returns only `totalResults`). `sortBy`, `attributes` and `excludedAttributes` are ignored.
* Filter operators: `eq ne co sw ew pr`, combined with `and`, `or`, `not(...)` and parentheses.
  `gt/ge/lt/le` are rejected (`400 invalidFilter`). Filterable attributes: users `id externalId userName
  displayName active emails.value name.givenName name.familyName`; groups `id externalId displayName
  members.value`. `id` and `externalId` compare case-exactly, other strings case-insensitively.
* `PATCH` supports `add`, `replace`, `remove`, with or without `path`. Paths may be schema-qualified
  (`urn:...:User:userName`), dotted (`name.givenName`) or use a value filter (`emails[type eq "work"].value`,
  `members[value eq "<id>"]`). On groups, `members` supports add, replace, remove-all, remove by filter and remove
  by value list. A PATCH is atomic: if any operation fails nothing is applied.
* Not supported (advertised as such in `/ServiceProviderConfig`): bulk, sort, ETags, change-password.
* Errors use the SCIM error schema with `application/scim+json`.

## Audit

Every mutation is written through the auth audit log (`auth-audit.jsonl`, SIEM export) with the caller as subject
(`scim` for the static token, `scim:<subject>` for an API token) and only the `userName` / group `displayName`
as detail: `scim_user_created`, `scim_user_updated`, `scim_user_deactivated`, `scim_user_reactivated`,
`scim_user_deleted`, `scim_group_created`, `scim_group_updated`, `scim_group_members_changed`,
`scim_group_deleted`, `scim_access_changed` (role/tenant changed, with the new role). Tokens and e-mail addresses are never logged. Failed
authentication is logged to the server log only (not the audit file) so unauthenticated callers cannot grow it.

## Configuring an IdP

Generic SCIM 2.0 client settings: base URL `https://<zeus-host>/scim/v2`, authentication "HTTP header / bearer
token" with the value of `ZEUS_OS_SCIM_TOKEN`, unique identifier field `userName`. This server has been tested
against its own automated test-suite only, **not against live Okta or Entra ID tenants**, and this page does not
reproduce vendor UI steps or vendor behaviour claims. What to check in whichever IdP you use:

* **Okta (SCIM 2.0 app integration) and Microsoft Entra ID (enterprise application provisioning)** both offer a
  generic SCIM 2.0 mode with bearer-token authentication: point it at the base URL and paste the token.
* Enable create / update / deactivate actions; leave **password sync off** (a password is rejected with `400`).
* Map `userName` to a value that satisfies the `userName` rules above (for example the sign-in name or mail).
* Push groups whose names match the mapping table (`zeus-os-editors`, `zeus-os-tenant-acme`, ...). Groups
  with other names are stored but grant nothing.
* Zeus accepts the common client request shapes: `filter=userName eq "..."` / `externalId eq "..."` lookups,
  PATCH with or without `path`, string booleans (`"True"`/`"False"`) for `active`, member removal by
  `members[value eq "<id>"]` or by value list, and `PUT` of a whole resource.
* Use the IdP's "test connection" or provisioning log together with `GET /ServiceProviderConfig` when debugging.

If provisioning fails, the SCIM error body in the IdP's provisioning log states the reason (`scimType` and
`detail`); a `409` means the user name or `externalId` already exists, `403` on a user name means it is reserved.

## Operational notes

* SCIM requires the local user store (`ZEUS_OS_LOCAL_USERS_FILE`, default `data/zeus-os-users.json`) to be on
  persistent storage; if Zeus runs in a mode that does not otherwise initialise it, the first SCIM request
  creates it (and its break-glass `admin`, with the usual generated or `ZEUS_OS_LOCAL_ADMIN_PASSWORD` password).
* Write operations are serialised in-process; multi-replica deployments must share the data directory (the
  same requirement as the rest of the local auth store).
* Manual role edits made through `/api/v1/auth/users` to a SCIM-managed user are overwritten by the group mapping
  the next time SCIM changes anything.
* `ZEUS_OS_SCIM_*` variables are read per request, so the kill-switch and mapping changes need no restart
  when set through the process environment; the static token change also takes effect immediately.
* SCIM requests are not subject to the per-actor API rate limiter; put a reverse-proxy limit in front if the
  endpoint is internet-reachable.
