# VM workbench

## Purpose

Full-page operations surface for one virtual machine: power, console, hardware, networking, backup panels, guest agent, and remote access.

## When to use it

- Start, stop, restart, or pause a specific VM
- Open VNC / serial / remote access
- Hot-plug CPU, memory, or disks
- Inspect guest OS / agent data
- Run backup, HA, or affinity controls for that VM

## How to get there

- Route: `/vms/:namespace/:name`
- From **VMs** inventory — click a row
- Command palette — search the VM name (when indexed)

## Operate from the console (UX)

1. Open `/vms/:namespace/:name` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Full-page operations surface for one virtual machine: power, console, hardware, networking, backup panels, guest agent, ….
3. Filter by namespace / name; open a row into the VM workbench (`/vms/<ns>/<name>`).
4. Power actions (Start / Stop / Restart / Pause) live on the workbench — not the browse list.
5. Open consoles (VNC needs HTTPS), disks, or migration tools from the workbench tabs.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Full-page operations surface for one virtual machine: power, console, hardware, networking, backup p.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](vms.md)
- [Consoles overview](../consoles/overview.md)
- [Disk Manager](../cluster/disk-manager.md)
- [PacketWolf](../more/packetwolf.md) — contain this VM’s traffic
