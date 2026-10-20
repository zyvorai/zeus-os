# DataVolumes

## Purpose

CDI DataVolume inventory — disk import/clone/upload jobs that back VM disks.

## When to use it

- Watch ISO/image import progress
- Debug “VM stuck pending” while DV is Importing
- Confirm PVC bound after DV succeeds

## How to get there

- Route: `/datavolumes`
- Nav: **Cluster → DataVolumes**

## Operate from the console (UX)

1. Open `/datavolumes` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: CDI DataVolume inventory — disk import/clone/upload jobs that back VM disks.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: CDI DataVolume inventory — disk import/clone/upload jobs that back VM disks.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VM setup](../core/vm-setup.md)
- [Storage](storage.md)
- [Image Library](../../PAGE_INDEX.md) — `/image-library`
