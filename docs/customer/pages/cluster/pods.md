# Pods

## Purpose

Kubernetes pod inventory — including `virt-launcher` pods that back running VMIs.

## When to use it

- Debug scheduling failures behind a stuck VM
- Inspect restarts, node assignment, and ages
- Bridge VM ops and raw Kubernetes troubleshooting

## How to get there

- Route: `/pods`
- Nav: **Cluster → Pods**
- Related workspace: **Kubernetes**

## Operate from the console (UX)

1. Open `/pods` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Kubernetes pod inventory — including `virt-launcher` pods that back running VMIs.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Kubernetes pod inventory — including `virt-launcher` pods that back running VMIs.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VM Instances](../core/vmis.md)
- [Nodes](nodes.md)
- [Events](../../PAGE_INDEX.md) — `/events`
