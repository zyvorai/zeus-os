# WebAuthn second factor (passkeys / security keys)

Zeus OS can require a **WebAuthn** credential (a hardware security key or a
passkey with user verification) after the password for **local** logins. It is
**off by default**: with no configuration the login behaves exactly as before
and the credential store is never read.

Scope: the built-in local user login (`/api/v1/auth/login` in local mode,
`/api/v1/auth/local/login` — the break-glass login — in LDAP/SAML/OIDC modes).
It does not add a second factor to the IdP-driven SSO/LDAP logins; enforce MFA
at the IdP for those.

Code: `web/src/webauthn.rs` (state machine, credential and challenge stores),
`web/src/routes/webauthn.rs` (HTTP), `web/src/local_auth.rs` (login gate),
`ui/src/services/webauthnService.ts`, `ui/src/stores/authStore.ts`,
`ui/src/components/security/{LoginMfaStep,WebAuthnSettings}.tsx`.

## Enabling

The relying-party identity is deployment specific and is **not** guessed.

| Variable | Meaning |
|----------|---------|
| `ZEUS_OS_WEBAUTHN_RP_ID` | Relying-party ID: the registrable domain the UI is served from, e.g. `zeus.example.com`. Credentials are bound to it — changing it invalidates every registered key. |
| `ZEUS_OS_WEBAUTHN_ORIGIN` | Exact browser origin(s) of the UI, comma separated, e.g. `https://zeus.example.com,https://zeus.example.com:30050`. The first is primary. The origin's host must equal or be a subdomain of the RP ID. |
| `ZEUS_OS_WEBAUTHN_RP_NAME` | Optional display name (default `Zeus OS`). |
| `ZEUS_OS_WEBAUTHN_TOTP_RECOVERY` | Optional, `1` to allow TOTP recovery (see below). Default off. |

States:

* **Both unset** — disabled. No routes act, login is unchanged.
* **Both set and valid** — enabled.
* **Only one set, or invalid** — *misconfigured*: it fails closed. Users who
  have credentials (or whenever the store cannot be read) get `503` on login
  instead of a password-only session; users without credentials still log in.
  The log line `webauthn unavailable` carries the reason.

Browsers only expose WebAuthn on HTTPS (or `localhost`), and the origin the
browser sees must match `ZEUS_OS_WEBAUTHN_ORIGIN` exactly, including the port.

## Flow

1. **Register** (Settings → Security → *Security keys*). The signed-in user
   re-enters their password, the server issues a registration challenge, the
   browser prompts for the key, the server verifies and stores the public key.
   Up to 10 keys per user. User verification (PIN/biometric) is required.
2. **Login.** `POST /auth/login` with a correct password and at least one
   registered key answers `200`:
   ```json
   { "mfa_required": true, "methods": ["webauthn"], "mfa_token": "…",
     "webauthn": { "publicKey": { … } }, "expires_in": 180 }
   ```
   **No session token exists at this point.** The client runs
   `navigator.credentials.get()` and posts
   `POST /auth/webauthn/login/finish {mfa_token, credential}`; only a verified
   assertion returns the normal login body (`token`, `role`, …).
3. Users with no registered key get the normal session straight after the
   password.

Security properties:

* Challenges are server side, in memory only, **single use**, expire after 180 s,
  and are bound to the user and the ceremony kind (a registration challenge
  cannot complete a login and vice versa; another user cannot complete yours).
  `mfa_token` is 256 random bits. At most 4096 ceremonies are pending at once.
* User verification is required; the sign counter is checked and a regression
  (possible cloned key) rejects the login and writes `webauthn_clone_suspected`.
  The updated counter is persisted before the session is issued — if that write
  fails, login fails.
* Every verification attempt consumes its `mfa_token`; after a failure the user
  starts again from the password step. Failed assertions/registrations count
  against the login rate limiter (key `webauthn:<user>`, 10 failures / 15 min,
  then `429`), separate from the password counter.
* Adding or removing a key requires the account password again (a stolen
  session cannot silently add a persistent second factor).
* Only public keys, credential ids, sign counters and labels are stored:
  `<ZEUS_OS_DATA_DIR>/webauthn-credentials.json`, mode `0600`, atomically
  replaced. A missing file means "no keys"; an unreadable/corrupt file is an
  error (login fails closed) and the file is left untouched. Challenges and
  credential bodies are never logged.

## API

Public (complete a password login): `POST /api/v1/auth/webauthn/login/finish`,
`POST /api/v1/auth/webauthn/login/recover`.

Authenticated (`Authorization: Bearer`): `GET /api/v1/auth/webauthn/status`,
`POST /api/v1/auth/webauthn/register/start` `{label, password}`,
`POST /api/v1/auth/webauthn/register/finish` `{credential}`,
`POST /api/v1/auth/webauthn/credentials/{id}/remove` `{password}`,
`DELETE /api/v1/auth/webauthn/users/{username}/credentials` (admin only).

These routes are deliberately outside the viewer write-block so every role can
manage its **own** keys; each handler acts only on the caller's own subject, and
the admin reset does an exact `role == "admin"` check itself.

## Recovery

* **Another registered key.** Register at least two keys.
* **Admin reset** (always available): an admin calls
  `DELETE /api/v1/auth/webauthn/users/{username}/credentials`. The user can then
  log in with the password alone and re-register. Audited as
  `webauthn_admin_reset` (subject = admin, detail = target and count).
* **TOTP** (opt-in): with `ZEUS_OS_WEBAUTHN_TOTP_RECOVERY=1` the `mfa_required`
  answer also lists `"totp"`, and `POST /auth/webauthn/login/recover
  {mfa_token, code}` accepts a code from the user's existing authenticator
  enrolment (`/auth/mfa/*`, secrets in the `zeus-os-mfa-secrets` Kubernetes
  Secret). This is a weaker path than a key; leave it off if you want
  phishing-resistant MFA only. Audited as `webauthn_recovery_totp`.
  (Today TOTP is otherwise only used for console step-up, not at login.)
* **Locked out with no admin left.** Stop the server, delete the user's entry
  from `webauthn-credentials.json` (or the whole file) or unset
  `ZEUS_OS_WEBAUTHN_RP_ID`/`_ORIGIN` to disable the feature, and restart. Deleting
  a local user also removes their keys.

## Audit events (`auth-audit.jsonl`, SIEM as `auth.<event>`)

`login_mfa_required`, `login_mfa_unavailable`, `webauthn_register`,
`webauthn_register_failure`, `webauthn_remove`, `webauthn_login_success`,
`webauthn_login_failure`, `webauthn_clone_suspected`, `webauthn_locked_out`,
`webauthn_reauth_failure`, `webauthn_admin_reset`,
`webauthn_admin_reset_denied`, `webauthn_recovery_totp`,
`webauthn_recovery_failure`, plus the normal `login` (detail `local+webauthn`
or `local+totp-recovery`).

## Operational notes

* Challenge state lives in the process. Run one replica (or sticky sessions) for
  the login/registration ceremonies; a restart between the two steps just makes
  the user retry.
* The credential file is per data directory; back it up with the rest of
  `ZEUS_OS_DATA_DIR`.

## Testing

Automated (no browser, no server): `cargo test -p zeus-os-web --bins webauthn`
uses `webauthn-authenticator-rs`'s software passkey as a virtual authenticator
against the real ceremony code and the real login/finish handlers, covering the
password → `mfa_required` → session state machine, single-use/TTL challenges,
clone detection, rate limiting, fail-closed store handling and the disabled
default. UI: `cd ui && npx vitest run src/services/webauthnService.test.ts
src/stores/authStoreMfa.test.ts src/components/security`.

Manual browser check with a virtual authenticator (not automated in CI because
it needs a running server and a matching RP ID/origin):

1. `ZEUS_OS_WEBAUTHN_RP_ID=localhost ZEUS_OS_WEBAUTHN_ORIGIN=http://localhost:5050
   cargo run -p zeus-os-web` (serve the built UI, or use the Vite dev server with
   origin `http://localhost:3000` added to the comma list).
2. In Chrome DevTools → three-dot menu → More tools → **WebAuthn**, tick *Enable
   virtual authenticator environment*, add an authenticator: protocol `ctap2`,
   transport `internal` (or `usb`), tick *Supports user verification* and
   *Automatic presence simulation* / *Set user verified*.
   With Playwright/CDP the equivalent is `WebAuthn.enable` +
   `WebAuthn.addVirtualAuthenticator {protocol:'ctap2', transport:'internal',
   hasUserVerification:true, isUserVerified:true, automaticPresenceSimulation:true}`.
3. Sign in as `admin`, open Settings → Security → *Security keys*, add a key
   (the virtual authenticator answers automatically), sign out, sign in again:
   after the password the *Use security key* step appears and completes with
   the virtual authenticator. Remove the authenticator in DevTools and confirm
   the login step then cannot be completed (recover via admin reset).
