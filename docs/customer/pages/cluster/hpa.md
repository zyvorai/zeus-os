# HPA

## Purpose

Monitor and manage Horizontal Pod Autoscalers — replica counts, CPU utilization, and scaling status across namespaces.

## When to use it

- See which workloads are at min/max or actively scaling
- Create an HPA for a Deployment or similar target
- Delete an unused autoscaler
- Search HPAs by name, namespace, or target

## How to get there

- Route: `/hpa`
- Nav: **Cluster → HPA**
- Related: `/vpa`, `/pods`, `/rightsizing`

## Operate from the console (UX)

1. Open `/hpa` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Monitor and manage Horizontal Pod Autoscalers — replica counts, CPU utilization, and scaling status across namespaces.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Monitor and manage Horizontal Pod Autoscalers — replica counts, CPU utilization, and scaling status .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VPA](./vpa.md)
- [Pods](./pods.md)
- [Rightsizing](../cost/rightsizing.md)
