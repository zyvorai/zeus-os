# Priority Classes

## Purpose

Read-only list of Kubernetes PriorityClass objects — numeric value, global default, preemption policy, and usage.

## When to use it

- Find the global default priority class
- Compare priority values before assigning workloads
- See which classes allow preempting lower-priority pods
- Diagnose 403/401 if RBAC blocks listing PriorityClass

## How to get there

- Route: `/priority-classes`
- Nav: **Cluster → Priority Classes**
- Related: `/runtime-classes`, `/taints`, `/pods`

## Operate from the console (UX)

1. Open `/priority-classes` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only list of Kubernetes PriorityClass objects — numeric value, global default, preemption policy, and usage.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only list of Kubernetes PriorityClass objects — numeric value, global default, preemption polic.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Runtime Classes](./runtime-classes.md)
- [Taints](./taints.md)
- [Pods](./pods.md)
