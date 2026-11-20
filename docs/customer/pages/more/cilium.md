# Cilium CNI

## Purpose

Cilium status, endpoints, policies, Hubble packet flows, VM internet-egress controls, and a VM policy builder — when Cilium is installed in the cluster.

## When to use it

- Confirm Cilium and Hubble availability
- List endpoints and CiliumNetworkPolicies
- Apply or remove cluster-wide virt-launcher internet egress policy
- Build per-VM Cilium policies; correlate with PacketWolf containment

## How to get there

- Route: `/cilium`
- Nav: **More → Mesh & traffic → Cilium CNI**
- Related: `/network-flow`, `/packetwolf`

## Operate from the console (UX)

1. Open `/cilium` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Cilium status, endpoints, policies, Hubble packet flows, VM internet-egress controls, and a VM policy builder — when Cil….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Cilium status, endpoints, policies, Hubble packet flows, VM internet-egress controls, and a VM polic.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Network Flow](./network-flow.md)
- [PacketWolf VM Guard](./packetwolf.md)
- [Security](../security/security.md)
