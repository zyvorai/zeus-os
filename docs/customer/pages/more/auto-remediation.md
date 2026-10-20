# Auto-Remediation

## Purpose

Day-2 playbooks and policy controls that respond to common VM failures — crash loops, node pressure migrations, and advisory rightsizing or PVC expansion — with optional closed-loop autonomy.

## When to use it

- Arm restart or migrate responses for recurring VM faults
- Review the engine operations queue before or after autonomy runs
- Keep high-CPU / PVC expansion as advisory-only guidance
- Disable automation during change freezes

## How to get there

- Route: `/auto-remediation`
- Nav: **More → Insights → Auto-Remediation**
- Related: `/anomaly-detector`, `/ai-center`, `/incidents`

## Operate from the console (UX)

1. Open `/auto-remediation` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Day-2 playbooks and policy controls that respond to common VM failures — crash loops, node pressure migrations, and advi….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Day-2 playbooks and policy controls that respond to common VM failures — crash loops, node pressure .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Anomaly Detector](./anomaly-detector.md)
- [AI Center](./ai-center.md)
- [Incidents](../observe/incidents.md)
- [Migrations](../run/migrations.md)
- [VMs](../core/vms.md)
