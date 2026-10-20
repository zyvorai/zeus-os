# DNS

## Purpose

Derived DNS / FQDN helpers for pods and VMs: search inventory, copy cluster-style names, and map IPs to names operators can use.

## When to use it

- Look up a pod or VM DNS name during connectivity troubleshooting
- Copy an FQDN or IP for curl, dig, or firewall rules
- Confirm guest/pod IP coverage after a deploy
- Filter a large inventory by name or namespace

## How to get there

- Route: `/dns`
- Nav: **More → Tools & settings → DNS**
- Related: `/vms`, `/pods`, `/network-flow`

## Operate from the console (UX)

1. Open `/dns` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Derived DNS / FQDN helpers for pods and VMs: search inventory, copy cluster-style names, and map IPs to names operators ….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Derived DNS / FQDN helpers for pods and VMs: search inventory, copy cluster-style names, and map IPs.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [PacketWolf VM Guard](./packetwolf.md)
- [Pods](../../PAGE_INDEX.md) — `/pods`
- [Network Flow](../../PAGE_INDEX.md) — `/network-flow`

