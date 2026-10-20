# Patch Center

## Purpose

Windows and Linux patch readiness across running VMs — risk signals, maintenance-window links, and compliance handoff.

## When to use it

- Measure fleet patch readiness percentage
- Find VMs that need review or are high risk
- Follow the pre-patch snapshot → apply → reboot → health-check flow
- Schedule off-peak work via Scheduled Ops

## How to get there

- Route: `/patch-center`
- Nav: **Compute → Patch Center**
- Related: `/vm-groups`, `/events?tab=scheduled`, `/compliance`, `/snapshots`

## Operate from the console (UX)

1. Open `/patch-center` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Windows and Linux patch readiness across running VMs — risk signals, maintenance-window links, and compliance handoff.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Windows and Linux patch readiness across running VMs — risk signals, maintenance-window links, and c.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VM Groups](./vm-groups.md)
- [Snapshots](../run/snapshots.md)
- [Security](../security/security.md)
