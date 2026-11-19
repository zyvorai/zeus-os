# MetalLB & external IPs

## Purpose

Operator guidance for LoadBalancer Services (SSH, RDP, and other external access) via MetalLB address pools — not a pool editor UI.

## When to use it

- Check whether the MetalLB IPAddressPool API is present
- See how many IPAddressPool objects exist
- Follow L2 or BGP configuration examples
- Understand deploy-time env vars for optional MetalLB install

## How to get there

- Route: `/metallb-external-ips`
- Nav: **Cluster → MetalLB & external IPs**
- Related: `/services`, `/vms`

## Operate from the console (UX)

1. Open `/metallb-external-ips` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Operator guidance for LoadBalancer Services (SSH, RDP, and other external access) via MetalLB address pools — not a pool….
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Operator guidance for LoadBalancer Services (SSH, RDP, and other external access) via MetalLB addres.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Services](./services.md)
- [VMs](../core/vms.md)
- [VM workbench](../core/vm-workbench.md)
