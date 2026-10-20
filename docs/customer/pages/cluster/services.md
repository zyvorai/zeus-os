# Services

## Purpose

Cluster-wide Kubernetes Service inventory for VM SSH/RDP exposes and other workloads — ports, addresses, and YAML in one place.

## When to use it

- Find the NodePort or LoadBalancer address for a VM
- Filter Zeus-managed SSH/RDP/pod Services
- Copy a primary address without leaving the dashboard
- Confirm ClusterIP and port mappings before opening a firewall

## How to get there

- Route: `/services`
- Nav: **Cluster → Services**
- Related: `/metallb-external-ips`, `/vms`

## Operate from the console (UX)

1. Open `/services` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Cluster-wide Kubernetes Service inventory for VM SSH/RDP exposes and other workloads — ports, addresses, and YAML in one….
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Cluster-wide Kubernetes Service inventory for VM SSH/RDP exposes and other workloads — ports, addres.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [MetalLB & external IPs](./metallb-external-ips.md)
- [VMs](../core/vms.md)
- [Pods](./pods.md)
