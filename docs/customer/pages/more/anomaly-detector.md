# Anomaly Detector

## Purpose

Surfaces VM health, CPU, and memory outliers with risk levels and suggested next actions. The view auto-refreshes about every 10 seconds from live inventory and health scores.

## When to use it

- Triage noisy or degrading VMs before an incident page
- Spot sustained high CPU or memory before capacity work
- Confirm the cluster looks clear after a remediation
- Feed Auto-Remediation or Incidents with concrete targets

## How to get there

- Route: `/anomaly-detector`
- Nav: **More → Insights → Anomaly Detector**
- Related: `/auto-remediation`, `/ai-center`, `/incidents`

## Operate from the console (UX)

1. Open `/anomaly-detector` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Surfaces VM health, CPU, and memory outliers with risk levels and suggested next actions. The view auto-refreshes about ….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Surfaces VM health, CPU, and memory outliers with risk levels and suggested next actions. The view a.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Auto-Remediation](./auto-remediation.md)
- [AI Center](./ai-center.md)
- [Incidents](../observe/incidents.md)
- [VMs](../core/vms.md)
