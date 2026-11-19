# Runtime Classes

## Purpose

Read-only inventory of cluster RuntimeClass objects — handler, scheduling hints, overhead, and usage counts.

## When to use it

- Confirm which runtime handlers exist (for example kata, gvisor, runc)
- See CPU/memory overhead configured on a class
- Check how many workloads reference each class
- Sort or search before assigning `runtimeClassName` on pods/VMs elsewhere

## How to get there

- Route: `/runtime-classes`
- Nav: **Cluster → Runtime Classes**
- Related: `/priority-classes`, `/pods`, `/nodes`

## Operate from the console (UX)

1. Open `/runtime-classes` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only inventory of cluster RuntimeClass objects — handler, scheduling hints, overhead, and usage counts.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only inventory of cluster RuntimeClass objects — handler, scheduling hints, overhead, and usage.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Priority Classes](./priority-classes.md)
- [Pods](./pods.md)
- [Nodes](./nodes.md)
