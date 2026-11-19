# Image Registry

## Purpose

Browse container disk images for KubeVirt VMs — cluster images from running pods, or a reference catalog — then open Create VM with the image prefilled.

## When to use it

- Pick a containerdisk / cloud image for a new VM
- Copy a full image URL (`registry/repo:tag`)
- Enter a custom image reference and quick-spawn with defaults
- Fall back to the built-in reference catalog when the cluster list is empty

## How to get there

- Route: `/image-registry`
- Nav: **Cluster → Image Registry**
- Related: `/vms`, `/image-library`, `/images-volumes`

## Operate from the console (UX)

1. Open `/image-registry` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Browse container disk images for KubeVirt VMs — cluster images from running pods, or a reference catalog — then open Cre….
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Browse container disk images for KubeVirt VMs — cluster images from running pods, or a reference cat.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Image Library](./image-library.md)
- [Image library](./image-library.md)
- [VMs](../core/vms.md)
- [VM setup](../core/vm-setup.md)
