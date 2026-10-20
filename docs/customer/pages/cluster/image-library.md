# Image Library

## Purpose

One catalog for golden images, import guidance, and cluster images so operators can pick OS media when creating VMs.

## When to use it

- Browse golden templates and container disks before deploy
- See cluster-discovered images
- Open Create VM with an image reference prefilled
- Find links into DataVolumes, Image Factory, or Migration Factory for imports

## How to get there

- Route: `/image-library`
- Nav: **Cluster → Image Library**
- Related: `/vms`, `/datavolumes`, `/image-factory`, `/templates`

## Operate from the console (UX)

1. Open `/image-library` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: One catalog for golden images, import guidance, and cluster images so operators can pick OS media when creating VMs.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: One catalog for golden images, import guidance, and cluster images so operators can pick OS media wh.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [DataVolumes](./datavolumes.md)
- [Image Factory](./image-factory.md)
- [Templates](./templates.md)
- [VMs](../core/vms.md)
