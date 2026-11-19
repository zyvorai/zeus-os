# VM Groups

## Purpose

Label-based VM groups with bulk start, stop, and restart across matching members.

## When to use it

- Define a fleet slice with a label selector (`app=web, env=prod`)
- Start, stop, or restart all VMs in a group
- Scope groups to a namespace when needed
- Clean up obsolete group definitions

## How to get there

- Route: `/vm-groups`
- Nav: **Compute → VM Groups** (also contextual under Machines)
- Related: `/vms`, `/infra-browser`, `/patch-center`

## Operate from the console (UX)

1. Open `/vm-groups` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Label-based VM groups with bulk start, stop, and restart across matching members.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Label-based VM groups with bulk start, stop, and restart across matching members.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [Machine Finder](./infra-browser.md)
- [Patch Center](./patch-center.md)
