# Network Info

## Purpose

Host network interface inventory for the Zeus OS host — physical, bridge, veth, VM TAP, Cilium, bond, VLAN, and tunnel devices — with traffic counters.

## When to use it

- Confirm which NICs are up after a host network change
- Find VM TAP (`vnet*`) or Cilium interfaces during connectivity triage
- Copy MAC or IP addresses for tickets or firewall rules
- Spot high RX/TX interfaces before blaming a guest VM

## How to get there

- Route: `/network-info`
- Nav: **Observe → Network Info**
- Related: `/host`, `/packetwolf`

## Operate from the console (UX)

1. Open `/network-info` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Host network interface inventory for the Zeus OS host — physical, bridge, veth, VM TAP, Cilium, bond, VLAN, and tunnel d….
3. Filter firing vs resolved; open an incident or alert for guided remediation.
4. Jump to related VMs/pods/nodes from the detail panel.
5. Silence only with an expiry when paging must pause — keep the alert visible in-ledger.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Host network interface inventory for the Zeus OS host — physical, bridge, veth, VM TAP, Cilium, bond.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Host Info](./host.md)
- [PacketWolf](../more/packetwolf.md)
- [VM Workbench](../core/vm-workbench.md)
- [Topology](../more/topology.md)
