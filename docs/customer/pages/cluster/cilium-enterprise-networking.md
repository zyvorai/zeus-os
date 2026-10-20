# Enterprise networking

## Purpose

Direct management of Cilium-native Egress Gateway policies, BGP peering, L2 announcement policies,
and Gateway API `Gateway`/`HTTPRoute` objects — no separate controller or CRD editing required.

## When to use it

- Pin a set of pods' outbound traffic to a stable IP via a chosen gateway node
- Peer the cluster with an upstream router over BGP, or announce Service IPs over L2 as an
  alternative to MetalLB
- Expose a VM's Service through the Kubernetes Gateway API instead of classic Ingress, for
  richer per-route traffic splitting and header matching

## How to get there

- Route: `/cilium-enterprise-networking`
- Nav: **Cluster → Enterprise networking**
- Related: `/metallb-external-ips`, `/network-attachments`, `/network-flow?tab=firewall`

## Operate from the console (UX)

1. Open `/cilium-enterprise-networking` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Direct management of Cilium-native Egress Gateway policies, BGP peering, L2 announcement policies, and Gateway API `Gate….
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Direct management of Cilium-native Egress Gateway policies, BGP peering, L2 announcement policies, a.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [MetalLB & external IPs](./metallb-external-ips.md)
- [Network hub (Firewall tab)](../more/network-flow.md)
