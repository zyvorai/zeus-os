# PVC Resize

## Purpose

Expand existing PersistentVolumeClaims or create empty PVCs. CDI image imports still belong on DataVolumes.

## When to use it

- Grow a VM disk claim that is running out of space
- Create a blank PVC in a namespace before attaching it
- Pick storage class and access mode for a new claim
- Deep-link with `?namespace=` and `?pvc=` from other storage views

## How to get there

- Route: `/pvc-resize`
- Nav: **Cluster → PVC Resize**
- Related: `/storage`, `/disk-manager`, `/datavolumes`

## Operate from the console (UX)

1. Open `/pvc-resize` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Expand existing PersistentVolumeClaims or create empty PVCs. CDI image imports still belong on DataVolumes.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Expand existing PersistentVolumeClaims or create empty PVCs. CDI image imports still belong on DataV.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Storage](./storage.md)
- [Disk Manager](./disk-manager.md)
- [DataVolumes](./datavolumes.md)
