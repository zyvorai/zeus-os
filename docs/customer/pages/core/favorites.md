# Favorites

## Purpose

Pinned VM list for quick access: star VMs you care about, search the fleet, and open VNC or serial console deep links.

## When to use it

- Keep critical VMs at the top of your day
- Jump to console without hunting the full inventory
- Confirm status, CPU, and memory for pinned guests
- Refresh after create/delete waves

## How to get there

- Route: `/favorites`
- Nav: **Core → Favorites**
- Related: `/vms`, `/widgets`, `/consolehub`

## Operate from the console (UX)

1. Open `/favorites` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Pinned VM list for quick access: star VMs you care about, search the fleet, and open VNC or serial console deep links.
3. Use filters and search on the page; open a row for detail / inspector.
4. Run the primary action (create, apply, run, export) from the PageHead or empty-state CTA.
5. Confirm success via toast + refreshed inventory; check Incidents if the action fails.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Pinned VM list for quick access: star VMs you care about, search the fleet, and open VNC or serial c.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](./vms.md)
- [VM workbench](./vm-workbench.md)
- [Widgets](../more/widgets.md)
- [Console Hub](../../PAGE_INDEX.md) — `/consolehub`
