# Network Flow

## Purpose

Zeus Network Center — service map, flows, DNS health, policies, and PacketWolf-backed containment actions, with Cilium/Hubble and cluster metrics as fallbacks when PacketWolf is offline.

## When to use it

- Investigate denied or unexpected flows
- Check DNS health for VM/workloads
- Quarantine or mark trusted traffic during an incident
- Review policies, threats, and capture tabs for day-2 network ops

## How to get there

- Route: `/network-flow`
- Nav: **More → Mesh & traffic → Network Flow**
- Related: `/packetwolf`, `/cilium`, `/dependencies`

## Operate from the console (UX)

1. Open `/network-flow` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Zeus Network Center — service map, flows, DNS health, policies, and PacketWolf-backed containment actions, with Cilium/H….
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Zeus Network Center — service map, flows, DNS health, policies, and PacketWolf-backed containment ac.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [PacketWolf VM Guard](./packetwolf.md)
- [Cilium CNI](./cilium.md)
- [Dependencies](./dependencies.md)
- [Security](../security/security.md)
- [Incidents](../observe/incidents.md)
