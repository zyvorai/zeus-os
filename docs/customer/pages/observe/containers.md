# Containers

## Purpose

Pod-centric container inventory with status stats, detail sheet, and (for non-viewers) deploy / apply-YAML shortcuts alongside a deployments panel.

## When to use it

- See Running / Failed / Pending pod counts at a glance
- Find pods by name, namespace, node, or linked VM name
- Open a pod sheet for containers, restarts, IP, and node
- Deploy a workload or apply YAML when your role allows
- Cross-check container health next to VM issues on the same nodes

## How to get there

- Route: `/containers`
- Nav: **Observe → Containers**
- Related: `/pods`, `/vms`

## Operate from the console (UX)

1. Open `/containers` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Pod-centric container inventory with status stats, detail sheet, and (for non-viewers) deploy / apply-YAML shortcuts alo….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Pod-centric container inventory with status stats, detail sheet, and (for non-viewers) deploy / appl.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Pods](../cluster/pods.md)
- [Virtual Machines](../core/vms.md)
- [VM Instances](../core/vmis.md)
- [Logs Explorer](./logs-explorer.md)
