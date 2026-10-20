# Machine Finder

## Purpose

Browse the datacenter → cluster → host → VM hierarchy, then jump into Machine Runway for fleet operations.

## When to use it

- Orient on where a VM sits in infrastructure topology
- Search hosts, VMs, or clusters by name
- Jump from a VM node into the VM inventory deep link
- Spot critical cluster storage pressure while browsing

## How to get there

- Route: `/infra-browser`
- Nav: **Workspace → Machine Finder** (module label Infrastructure Browser)
- Related: `/vms`, `/vm-groups`, `/topology`

## Operate from the console (UX)

1. Open `/infra-browser` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Browse the datacenter → cluster → host → VM hierarchy, then jump into Machine Runway for fleet operations.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Browse the datacenter → cluster → host → VM hierarchy, then jump into Machine Runway for fleet opera.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [VM Groups](./vm-groups.md)
- [Topology](../more/topology.md)
