# Enterprise SSO / OIDC (Keycloak)

How to sign into **Zeus OS** with a real identity provider — Keycloak, Auth0, Okta, or any
standards-compliant OIDC IdP — after install.

Zeus OS's OIDC relying-party implementation is generic (discovery + JWKS +
RS256/384/512 signature validation) and needs **zero code changes** for any real IdP.
Verified end-to-end live against a real Keycloak realm.

Unlike some products in the suite, Zeus OS does not bundle a Keycloak instance in its Helm
chart — you point it at a Keycloak (or other OIDC provider) you already have, or stand one up
separately. Whichever SSO mode is active, the built-in local admin account (`admin`, with
the password you set at install time) stays available underneath it automatically as a break-glass
fallback — the login screen shows a toggle between the two, not a hidden URL.

## Option A — Bring your own OIDC provider (Keycloak example)

1. **Create a realm and client in Keycloak.** Confidential client. **Valid Redirect URI**
   must be the real backend callback:

   ```text
   https://<zeus-host>:30050/api/v1/auth/oidc/callback
   ```

   Not `/auth/callback` — that's a *different*, frontend-only route the backend redirects
   the browser to *after* it has already validated the token server-side (carrying
   `?token=`, not an OAuth `code`/`state` pair). Registering the frontend route as the IdP
   redirect_uri breaks the flow silently — no error until the callback lands on the wrong
   page.

2. **Add a Group Membership protocol mapper** on the client's dedicated scope (Token Claim
   Name = `groups` by default, configurable via `ZEUS_OS_OIDC_GROUPS_CLAIM`; turn **Full
   group path** off, so the claim contains bare names like `zeus-os-admins`, not
   `/zeus-os-admins`). This mapper is included in every token issued to the client
   automatically — don't add `groups` to the requested OAuth scopes (see the gotcha below).

3. **If Keycloak is fronted by plain HTTP** (no TLS termination), its default
   `sslRequired=external` will reject every OIDC endpoint — including
   `/.well-known/openid-configuration` — with a generic `HTTPS required` error that has
   nothing to do with your Zeus OS config. Set the realm's **Require SSL → None** (Realm
   settings → General) for a lab/demo setup, or put real TLS in front of Keycloak for
   production.

4. **Deploy Zeus OS pointed at it:**

   ```bash
   cp contrib/zyvorai-oidc-keycloak.env.example my-oidc.env   # edit issuer/client-id for your realm
   set -a && source my-oidc.env && set +a
   ZEUS_OS_OIDC_CLIENT_SECRET='<secret from Keycloak Credentials tab>' \
     ./scripts/deploy-remote.sh <HOST> <SSH_USER> --with-oidc
   ```

   `--with-oidc` writes a Helm values file (not `--set`, since client secrets can contain
   characters `--set` mishandles) setting `config.authMode: oidc` and the full
   `config.oidc.*` block, including `groupAdmin`/`groupEditor` for role mapping. It survives
   the next `helm upgrade` since deploys always pass `--reuse-values`.

5. **Verify**: `GET /api/v1/auth/config` should return `mode: "oidc"`, `localFallback: true`,
   and an `oidc` block echoing your issuer/client-id/redirect-uri. Then a real browser login
   — click **Continue with OpenID Connect** on the sign-in screen.

Manual env-var reference (no deploy script): [Enterprise auth & tenancy](admin-basics.md)
links to the full `ENTERPRISE_AUTH_TENANCY.md` table (`ZEUS_OS_AUTH=oidc`,
`ZEUS_OS_OIDC_ISSUER`, `ZEUS_OS_OIDC_CLIENT_ID`, `ZEUS_OS_OIDC_CLIENT_SECRET`,
`ZEUS_OS_OIDC_REDIRECT_URI`, `ZEUS_OS_OIDC_SCOPES`, `ZEUS_OS_OIDC_GROUPS_CLAIM`,
`ZEUS_OS_OIDC_GROUP_ADMIN`, `ZEUS_OS_OIDC_GROUP_EDITOR`).

## Option B — LDAP / Active Directory instead

Zeus OS also speaks LDAP directly (`ZEUS_OS_AUTH=ldap`) if your organization uses Active
Directory rather than an OIDC IdP — see [Admin basics](admin-basics.md) for the resolution
order and `ENTERPRISE_AUTH_TENANCY.md` for the LDAP variable table. Local admin stays
available as break-glass here too.

## Option C — Local admin only (no IdP)

Leave `ZEUS_OS_AUTH` unset (the default). Sign in with the local admin account — set your own
password at install time (`config.localAuth.adminPassword` in Helm, or
reference a Secret via `config.localAuth.adminPasswordSecretRef`). See
[Admin basics — Local admin password](admin-basics.md#local-admin-password).

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `{"error":"invalid_request","error_description":"HTTPS required"}` from Keycloak | Realm's `sslRequired=external` rejecting a plain-HTTP request | Set Require SSL → None on the realm (lab), or put real TLS in front of Keycloak |
| `invalid_scope: Invalid scopes: ... groups` | `groups` (or another claim name) added to `ZEUS_OS_OIDC_SCOPES` | Remove it — `openid,profile,email` is enough; the group mapper applies regardless of requested scope |
| Redirects back but lands on the wrong page / generic error | Client's redirect_uri is `/auth/callback` instead of `/api/v1/auth/oidc/callback` | Fix the Valid Redirect URI in the IdP client to the real backend path |
| Logged in but role is always Viewer | Group claim not reaching the token, or group names don't match `ZEUS_OS_OIDC_GROUP_ADMIN`/`GROUP_EDITOR` | Use the IdP's token-evaluate/preview tool to confirm the `groups` claim is present and matches; check "Full group path" is off |
| Local admin missing from the login screen | Should not happen — it's automatic whenever an SSO mode is active | Check `GET /api/v1/auth/config` reports `localFallback: true`; file a bug if not |

## Related

- [Admin basics](admin-basics.md) — ports, deploy, local admin password, TLS
- [Getting Started](getting-started.md)
- Engineering mirror (same content, repo docs tree): [`ENTERPRISE_AUTH_TENANCY.md`](https://github.com/zyvorai/zeus-os/blob/main/docs/ENTERPRISE_AUTH_TENANCY.md#wiring-a-real-oidc-provider-keycloak-example)
- Sales / managed deploys: [zyvor.dev](https://zyvor.dev) · [sales@zyvor.dev](mailto:sales@zyvor.dev)
