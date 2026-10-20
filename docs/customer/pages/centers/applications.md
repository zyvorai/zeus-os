# Application Center

## Purpose

Group VMs into business applications with workspace scoping, health pulse, and an inspector for protection and membership.

## When to use it

- Model a service as an application over multiple VMs
- Filter applications by workspace or search
- Inspect health and linked VMs for one application
- Create an application with selected VM membership

## How to get there

- Route: `/applications`
- Nav: **Command palette / deep link**
- Related: `/vms`, `/backup-dr`, `/tasks`

## Operate from the console (UX)

1. Open `/applications` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Group VMs into business applications with workspace scoping, health pulse, and an inspector for protection and membershi….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Group VMs into business applications with workspace scoping, health pulse, and an inspector for prot.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [Backup & DR](./backup-dr.md)
- [Task Center](./tasks.md)
