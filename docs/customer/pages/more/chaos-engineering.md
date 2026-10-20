# Chaos Engineering

## Purpose

Controlled fault experiments against VMs — primarily kill virt-launcher pods to validate recovery; other stress types are listed when a fault-injection backend is available.

## When to use it

- Prove VM restart/recovery after pod death
- Game-day drills before production cutovers
- Validate Auto-Remediation or alerts fire correctly
- Document experiment results for change records

## How to get there

- Route: `/chaos-engineering`
- Nav: **More → Resilience → Chaos Engineering**
- Related: `/auto-remediation`, `/perf-testing`, `/vms`

## Operate from the console (UX)

1. Open `/chaos-engineering` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Controlled fault experiments against VMs — primarily kill virt-launcher pods to validate recovery; other stress types ar….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Controlled fault experiments against VMs — primarily kill virt-launcher pods to validate recovery; o.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Auto-Remediation](./auto-remediation.md)
- [Performance Testing](./perf-testing.md)
- [VMs](../core/vms.md)
- [Incidents](../observe/incidents.md)
