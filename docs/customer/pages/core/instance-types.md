# Instance types

## Purpose

Browse KubeVirt instance types and preferences — standardized CPU/memory shapes for consistent VM sizing.

## When to use it

- Pick a corporate-standard size before create
- Audit which shapes exist in the cluster
- Align FinOps rightsizing recommendations with catalog names

## How to get there

- Route: `/instance-types`
- Nav: **Core → Instance types**

## Operate from the console (UX)

1. Open `/instance-types` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Browse KubeVirt instance types and preferences — standardized CPU/memory shapes for consistent VM sizing.
3. Use filters and search on the page; open a row for detail / inspector.
4. Run the primary action (create, apply, run, export) from the PageHead or empty-state CTA.
5. Confirm success via toast + refreshed inventory; check Incidents if the action fails.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Browse KubeVirt instance types and preferences — standardized CPU/memory shapes for consistent VM si.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VM setup](vm-setup.md)
- [Rightsizing](../cost/rightsizing.md)
- [Templates](../cluster/templates.md)
