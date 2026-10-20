# Certificates

## Purpose

Tracks the TLS certificates in your cluster and how long each one has left, so an expiry never surprises you. Renewal can be triggered from the table.

## When to use it

- Weekly check for certificates expiring inside 30 days
- Find an already-expired certificate behind a TLS failure
- Force an early renewal ahead of a maintenance window
- Confirm a newly issued certificate reached Ready

## How to get there

- Route: `/certificates`
- Nav: **Security -> Certificates**
- Related: `/security`, `/compliance`, `/settings`

## Operate from the console (UX)

1. Open `/certificates` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Tracks the TLS certificates in your cluster and how long each one has left, so an expiry never surprises you. Renewal ca….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Tracks the TLS certificates in your cluster and how long each one has left, so an expiry never surpr.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Security](./security.md)
- [Compliance](./compliance.md)
- [External Secrets](./external-secrets.md)
- [Settings](../settings/settings.md)
