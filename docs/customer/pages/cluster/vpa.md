# VPA

## Purpose

List, create, and delete Vertical Pod Autoscalers, and inspect container resource recommendations.

## When to use it

- Review VPA update mode (Auto, Recreate, Initial, Off) for a workload
- Read target / lower / upper bound recommendations per container
- Create a VPA against a Deployment (or other kind)
- Remove a VPA so the controller stops managing requests

## How to get there

- Route: `/vpa`
- Nav: **Cluster → VPA**
- Related: `/hpa`, `/pods`, `/rightsizing`

## Operate from the console (UX)

1. Open `/vpa` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: List, create, and delete Vertical Pod Autoscalers, and inspect container resource recommendations.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: List, create, and delete Vertical Pod Autoscalers, and inspect container resource recommendations.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [HPA](./hpa.md)
- [Pods](./pods.md)
- [Rightsizing](../cost/rightsizing.md)
