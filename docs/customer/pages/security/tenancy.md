# Tenancy

## Purpose

Organise namespaces into tenants, see each tenant's namespace, CPU, and memory footprint, manage who belongs to a tenant, and track quota consumption per namespace.

## When to use it

- Onboard a new team as a tenant with its own tier and contact
- Add or remove a member's access to a tenant's namespaces
- Check which tenant is closest to exhausting its quota
- Report per-tenant CPU and memory usage back to a business unit

## How to get there

- Route: `/tenancy`
- Nav: **Security -> Tenancy**
- Related: `/users`, `/operations`, `/costs`

## Operate from the console (UX)

1. Open `/tenancy` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Organise namespaces into tenants, see each tenant's namespace, CPU, and memory footprint, manage who belongs to a tenant….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Organise namespaces into tenants, see each tenant's namespace, CPU, and memory footprint, manage who.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Users](./users.md)
- [Security](./security.md)
- [Operations](../run/operations.md)
- [Events (Audit log tab)](../observe/events.md)
