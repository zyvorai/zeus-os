# Virtual Machines

## Purpose

Inventory of every KubeVirt virtual machine you can see: live status, filters, and entry into the per-VM workbench.

## When to use it

- Find a VM by name, namespace, or status
- Confirm fleet health after a change
- Open a workbench for power, console, hardware, or guest ops
- Start bulk or group operations (where enabled)

## How to get there

- Route: `/vms`
- Nav: **Core → VMs** · workspace **VMs**

## Operate from the console (UX)

1. Open `/vms` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Inventory of every KubeVirt virtual machine you can see: live status, filters, and entry into the per-VM workbench.
3. Filter by namespace / name; open a row into the VM workbench (`/vms/<ns>/<name>`).
4. Power actions (Start / Stop / Restart / Pause) live on the workbench — not the browse list.
5. Open consoles (VNC needs HTTPS), disks, or migration tools from the workbench tabs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Inventory of every KubeVirt virtual machine you can see: live status, filters, and entry into the pe.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VM workbench](vm-workbench.md)
- [VM setup](vm-setup.md)
- [VM Instances](vmis.md) — running VMI objects
- [VM fleets](vmirs.md) — instance-type fleets / VMIRS
- REST: `GET /api/v1/vms`
