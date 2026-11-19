# Device Plugins

## Purpose

Read-only view of Kubernetes device-plugin resources and GPU capacity reported by the cluster.

## When to use it

- Confirm device plugins are registered and healthy
- See GPU allocation counts (total / allocated / available)
- Search plugins or GPU rows by name, node, or type
- Correlate with the GPU Devices page before binding hardware to VMs

## How to get there

- Route: `/device-plugins`
- Nav: **Cluster → Device Plugins**
- Related: `/gpu`, `/nodes`

## Operate from the console (UX)

1. Open `/device-plugins` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only view of Kubernetes device-plugin resources and GPU capacity reported by the cluster.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only view of Kubernetes device-plugin resources and GPU capacity reported by the cluster.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [GPU Devices](./gpu.md)
- [Nodes](./nodes.md)
- [Pods](./pods.md)
