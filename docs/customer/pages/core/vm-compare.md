# Compare VMs

## Purpose

Side-by-side diff of two VMs’ configuration so you can spot drift, clone mistakes, or environment mismatches.

## When to use it

- After cloning a VM
- When prod and staging “should match” but behave differently
- Auditing template drift

## How to get there

- Route: `/vm-compare`
- Nav: **Core → Compare VMs**

## Operate from the console (UX)

1. Open `/vm-compare` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Side-by-side diff of two VMs’ configuration so you can spot drift, clone mistakes, or environment mismatches.
3. Use filters and search on the page; open a row for detail / inspector.
4. Run the primary action (create, apply, run, export) from the PageHead or empty-state CTA.
5. Confirm success via toast + refreshed inventory; check Incidents if the action fails.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Side-by-side diff of two VMs’ configuration so you can spot drift, clone mistakes, or environment mi.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](vms.md)
- [VM workbench](vm-workbench.md)
