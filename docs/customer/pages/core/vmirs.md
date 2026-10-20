# VM fleets (VMIRS)

## Purpose

Manage VirtualMachineInstanceReplicaSet-style fleets — scale homogeneous VM groups as a unit.

## When to use it

- Stateless or similarly shaped VM pools
- Scale replica count without editing each VM
- Oversee fleet health in one place

## How to get there

- Route: `/vmirs`
- Nav: **Core → VM fleets**

## Operate from the console (UX)

1. Open `/vmirs` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Manage VirtualMachineInstanceReplicaSet-style fleets — scale homogeneous VM groups as a unit.
3. Use filters and search on the page; open a row for detail / inspector.
4. Run the primary action (create, apply, run, export) from the PageHead or empty-state CTA.
5. Confirm success via toast + refreshed inventory; check Incidents if the action fails.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Manage VirtualMachineInstanceReplicaSet-style fleets — scale homogeneous VM groups as a unit.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](vms.md)
- [AutoScaler](../../PAGE_INDEX.md) — `/autoscaler`
