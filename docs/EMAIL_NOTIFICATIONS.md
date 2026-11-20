# Email (SMTP) notification channel

Zeus OS can deliver notifications by email through any SMTP relay. Email is a
regular notification channel type (`email`) next to Slack, Teams, generic
webhook and PagerDuty, so it works everywhere a channel does: the Notifications
page, `POST /api/v1/notifications/channels/{id}/test`, `POST
/api/v1/notifications/send`, and the shortcut `notify` action.

Nothing is sent until an operator creates a channel. There is no default relay,
no default credentials, and tests never contact a real mail server.

## Channel config

Create the channel with `channel_type: "email"` and this `config`:

| Field | Required | Meaning |
|-------|----------|---------|
| `host` | yes | SMTP relay hostname or IP |
| `port` | no | Defaults from `security` (starttls 587, tls 465, none 25) |
| `security` | no | `starttls` (default, upgrade is mandatory), `tls` (implicit TLS), `none` (plaintext) |
| `username` | with password | SMTP AUTH user |
| `password` | one of the two | SMTP AUTH password, stored in the channel config, write-only (masked on read) |
| `password_env` | one of the two | Name of an environment variable on the Zeus OS server holding the password; keeps the secret out of the JSON store. Not masked (it is a name, not a secret) |
| `from` | yes | `zeus@example.com` or `Zeus OS <zeus@example.com>` |
| `to` | yes | List of addresses (a comma/semicolon/newline separated string is also accepted); at most 20, duplicates removed |
| `subject_prefix` | no | Prepended to the subject, e.g. `[prod]` |

```json
{
  "name": "ops-email",
  "channel_type": "email",
  "config": {
    "host": "smtp.example.com", "port": 587, "security": "starttls",
    "username": "alerts", "password_env": "ZEUS_OS_SMTP_PASSWORD",
    "from": "Zeus OS <zeus@example.com>",
    "to": ["ops@example.com", "oncall@example.com"],
    "subject_prefix": "[prod]"
  }
}
```

Validation happens at create/update time (no network): bad hosts, ports,
addresses, an empty recipient list, more than 20 recipients, both `password`
and `password_env`, a username without a password (or vice versa), and
credentials with `security: none` (credentials are never sent in plaintext) are
rejected with a 400 that names the problem.

## The message

A `multipart/alternative` message with a plain-text part and a simple HTML part:
`[SEVERITY] title`, the message body, and severity / source / time / metadata.

- Subject and all header fields have CR, LF and every other control character
  stripped (header injection), and are length-capped.
- Everything user-controlled is HTML-escaped in the HTML part.
- The body is capped at 32 KiB (`[message truncated]` is appended); at most 50
  metadata entries are included.
- Addresses are parsed strictly; addresses containing control characters are
  rejected rather than "cleaned".

## Honest delivery reporting

`ok` is true only when the SMTP server accepts the message (2xx reply to
`DATA`). `status_code` is the SMTP reply code (e.g. `250`); the test endpoint
also returns `"protocol": "SMTP"`. A rejected recipient (`550`), failed login
(`535`), TLS failure, timeout, blocked host, or unset `password_env` variable
is `ok: false` with the reason in `error`, and is recorded in the notification
history as `failed`. Passwords never appear in errors, logs or API responses.

Timeouts: 10 s per SMTP command/connect, 40 s for the whole exchange.

## Security posture (SSRF)

Same posture as the webhook channels:

- The relay host is resolved, **every** returned address is checked, and the
  connection goes to the checked IP (defeats DNS rebinding). TLS certificates
  are still verified against the configured hostname (webpki roots, rustls;
  no native-tls).
- Loopback, link-local (cloud metadata), private (RFC 1918/ULA), carrier-grade
  NAT, multicast/unspecified addresses and `localhost`, `*.local`, `*.svc`,
  `*.cluster.local`, `*.internal` names are refused.
- Only ports 25, 465, 587 and 2525 are accepted.

Operator switches (environment of the Zeus OS server; safe defaults are off):

| Variable | Effect |
|----------|--------|
| `ZEUS_OS_SMTP_ALLOW_PRIVATE=1` | Also permit RFC 1918 / ULA relay addresses and in-cluster hostnames (`mail.mail.svc`). Loopback, link-local/metadata and CGNAT stay blocked. |
| `ZEUS_OS_SMTP_EXTRA_PORTS=2526,1025` | Additional allowed SMTP ports |

Creating or editing channels needs the Editor role; sending a test needs
Editor as well. Channels are tenant-scoped like every other channel.

## Testing

`web/src/notification_dispatch.rs` contains an in-process fake SMTP server
(tokio `TcpListener` speaking EHLO/MAIL/RCPT/DATA/QUIT on `127.0.0.1`) used to
verify the recipients and body actually received, and the failure path when
the server rejects a recipient:

```bash
cargo test -p zeus-os-web --bins notification_dispatch
```

For a manual check against a real relay, create the channel in the UI and press
**Test** on its card; the result shows the SMTP reply code or the real error.
