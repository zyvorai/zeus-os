# VM Instances (VMI)

## Purpose

List of **running** VirtualMachineInstance objects — the live pods/instances behind VirtualMachine definitions.

## When to use it

- Debug “VM exists but nothing is running”
- See which node a live instance is on
- Correlate phase with migration or crash loops

## How to get there

- Route: `/vmis`
- Nav: **Core → VM Instances**

## Operate from the console (UX)

1. Open `/vmis` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: List of **running** VirtualMachineInstance objects — the live pods/instances behind VirtualMachine definitions.
3. Use filters and search on the page; open a row for detail / inspector.
4. Run the primary action (create, apply, run, export) from the PageHead or empty-state CTA.
5. Confirm success via toast + refreshed inventory; check Incidents if the action fails.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: List of **running** VirtualMachineInstance objects — the live pods/instances behind VirtualMachine d.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](vms.md)
- [Live Migrations](../run/migrations.md)
- [Pods](../../PAGE_INDEX.md) — `/pods` for the virt-launcher pod
