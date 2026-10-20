# Disk Manager

## Purpose

Manage VM disks: attach, hot-plug, resize entry points, and disk inventory beyond the raw PVC list.

## When to use it

- Add a data disk to a running VM
- Grow capacity (with PVC Resize / guest grow-fs as needed)
- Audit disks attached to a workload

## How to get there

- Route: `/disk-manager`
- Also: VM workbench hardware / disk panels

## Operate from the console (UX)

1. Open `/disk-manager` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Manage VM disks: attach, hot-plug, resize entry points, and disk inventory beyond the raw PVC list.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Manage VM disks: attach, hot-plug, resize entry points, and disk inventory beyond the raw PVC list.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Storage](storage.md)
- [VM workbench](../core/vm-workbench.md)
- [PVC Resize](../../PAGE_INDEX.md) — `/pvc-resize`
