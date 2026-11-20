# Networks

## Purpose

Multus NetworkAttachmentDefinition management so VMs can attach additional L2 NICs — bridge, macvlan, ipvlan, host-device, or SR-IOV.

## When to use it

- Add a second NIC / VLAN for a VM
- Create a Multus NAD and attach it to a guest in one wizard
- Inventory bridge vs macvlan vs SR-IOV attachments
- Remove an unused network definition

## How to get there

- Route: `/network-attachments`
- Nav: **Cluster → Networks**
- Related: `/vms`, `/device-plugins`

## Operate from the console (UX)

1. Open `/network-attachments` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Multus NetworkAttachmentDefinition management so VMs can attach additional L2 NICs — bridge, macvlan, ipvlan, host-devic….
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Multus NetworkAttachmentDefinition management so VMs can attach additional L2 NICs — bridge, macvlan.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VMs](../core/vms.md)
- [Device Plugins](./device-plugins.md)
- [MetalLB & external IPs](./metallb-external-ips.md)
