# GPU Devices

## Purpose

GPU / PCI passthrough inventory: host VGA/3D devices, allocation to VMs, plus a vGPU orchestration panel for mdev profiles and assign actions.

## When to use it

- See which host GPUs are free vs allocated
- Confirm IOMMU group, driver, and PCI address before passthrough
- Review VM GPU assignment rows
- Assign a GPU resource or host device to a VM from the vGPU panel

## How to get there

- Route: `/gpu`
- Nav: **Cluster → GPU Devices**
- Related: `/device-plugins`, `/vms`, `/nodes`

## Operate from the console (UX)

1. Open `/gpu` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: GPU / PCI passthrough inventory: host VGA/3D devices, allocation to VMs, plus a vGPU orchestration panel for mdev profil….
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: GPU / PCI passthrough inventory: host VGA/3D devices, allocation to VMs, plus a vGPU orchestration p.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Device Plugins](./device-plugins.md)
- [Nodes](./nodes.md)
- [VMs](../core/vms.md)
