# Storage

## Purpose

Storage and PVC intelligence for the cluster: volumes, capacity signals, and entry points into disk/resize workflows.

## When to use it

- See where VM disks live
- Spot full or failing storage classes
- Jump to resize, DataVolumes, or Disk Manager

## How to get there

- Route: `/storage`
- Nav: **Cluster → Storage** · workspace **Storage**

## Operate from the console (UX)

1. Open `/storage` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the editorial hero and **Get the highlights** (bound PVC ratio, PVC count, pending, classes), then use the PVC fleet / backends / profiles tabs.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Storage and PVC intelligence for the cluster: volumes, capacity signals, and entry points into disk/.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Disk Manager](disk-manager.md)
- [DataVolumes](datavolumes.md)
- [PVC Resize](../../PAGE_INDEX.md) — `/pvc-resize`
- [VM workbench](../core/vm-workbench.md)
