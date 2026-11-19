# Users

## Purpose

Shows who you are signed in as and what that identity may do, manages built-in local accounts, and issues revocable API tokens for automation.

## When to use it

- Onboard or offboard a local operator account
- Check whether the current session can delete VMs or manage network policies
- Mint an API token for CI, then revoke it when the pipeline is retired
- Copy the session bearer token for a quick API call

## How to get there

- Route: `/users`
- Nav: **Security -> Users**
- Related: `/security`, `/events?tab=audit`, `/tenancy`, `/settings`

## Operate from the console (UX)

1. Open `/users` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Shows who you are signed in as and what that identity may do, manages built-in local accounts, and issues revocable API ….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Shows who you are signed in as and what that identity may do, manages built-in local accounts, and i.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Security](./security.md)
- [Events (Audit log tab)](../observe/events.md)
- [Tenancy](./tenancy.md)
- [Change Approval](./change-approval.md)
- [Settings](../settings/settings.md)
