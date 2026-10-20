# Security

## Purpose

Security posture overview — findings, hardening status, and entry into compliance / scanning / policies.

## When to use it

- Periodic security review
- After onboarding a new namespace or tenant
- Before audits (pair with Compliance)

## How to get there

- Route: `/security` (also `/security-overview` / Security Operations depending on edition)
- Nav: **Security → Security**
- Related: `/compliance`, `/image-scanning`, `/admission-control`, `/opa`

## Operate from the console (UX)

1. Open `/security` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Security posture overview — findings, hardening status, and entry into compliance / scanning / policies.
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Security posture overview — findings, hardening status, and entry into compliance / scanning / polic.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [PacketWolf](../more/packetwolf.md)
- [Events → Audit log tab](../observe/events.md) — `/events?tab=audit`
- [Compliance](../../PAGE_INDEX.md) — `/compliance`
- [Users](../../PAGE_INDEX.md) — `/users`
