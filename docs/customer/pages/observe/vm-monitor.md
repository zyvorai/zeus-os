# VM Monitor

## Purpose

Activity Monitor for the VM fleet — live and historical CPU, memory, network, and disk — with per-VM charts and links into the VM workbench.

## When to use it

- Find which VMs are hottest on CPU, memory, network, or disk right now
- Watch fleet averages and top consumers during an incident
- Drill into one VM’s charts before opening the full workbench
- Compare live samples vs Prometheus history ranges

## How to get there

- Route: `/vm-monitor`
- Nav: **Observe → VM Monitor**
- Related: `/vms`, `/heatmap`, `/monitoring`

## Operate from the console (UX)

1. Open `/vm-monitor` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Activity Monitor for the VM fleet — live and historical CPU, memory, network, and disk — with per-VM charts and links in….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Activity Monitor for the VM fleet — live and historical CPU, memory, network, and disk — with per-VM.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [VM Workbench](../core/vm-workbench.md)
- [Resource Heatmap](./heatmap.md)
- [Monitoring Targets](./monitoring.md)
