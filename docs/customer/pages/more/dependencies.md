# Dependencies

## Purpose

Live graph of resource relationships — nodes, VMs, PVCs, Services, and labeled edges — so you can see what depends on what before a change.

## When to use it

- Estimate blast radius before drain, delete, or migrate
- Explain storage and service coupling to a new operator
- Correlate an incident with upstream/downstream objects
- Complement the Topology map with a dependency-focused layout

## How to get there

- Route: `/dependencies`
- Nav: **More → Mesh & traffic → Dependencies**
- Related: `/topology`, `/network-flow`, `/vms`

## Operate from the console (UX)

1. Open `/dependencies` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Live graph of resource relationships — nodes, VMs, PVCs, Services, and labeled edges — so you can see what depends on wh….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Live graph of resource relationships — nodes, VMs, PVCs, Services, and labeled edges — so you can se.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Topology](./topology.md)
- [Network Flow](./network-flow.md)
- [VMs](../core/vms.md)
- [Incidents](../observe/incidents.md)
