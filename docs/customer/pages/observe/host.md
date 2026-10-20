# Host Info

## Purpose

Read-only view of the Zeus OS host — OS, hardware, disks, NICs, and local services — for operators checking the control-plane node itself.

## When to use it

- Confirm host CPU, memory, disk, and load after a platform upgrade
- Inventory PCI devices and memory modules before GPU or device passthrough work
- Check NIC state and traffic counters when the UI or API feels slow
- See which systemd-style services are running on the Zeus host

## How to get there

- Route: `/host`
- Nav: **Observe → Host Info**
- Related: `/network-info`, `/system-health`

## Operate from the console (UX)

1. Open `/host` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only view of the Zeus OS host — OS, hardware, disks, NICs, and local services — for operators checking the control-….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only view of the Zeus OS host — OS, hardware, disks, NICs, and local services — for operators c.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Network Info](./network-info.md)
- [System Health](./system-health.md)
- [Nodes](../cluster/nodes.md)
