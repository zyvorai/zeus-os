# Customization Profiles

## Purpose

Reusable guest customization specs — cloud-init, Windows sysprep/unattend XML, and SSH authorized keys — applied from create/clone flows or onto an existing VM.

## When to use it

- Standardize Linux cloud-init across many VMs
- Store a Windows unattend / sysprep baseline
- Push SSH keys onto an existing guest without rewriting YAML by hand
- Share a named profile with operators who create VMs

## How to get there

- Route: `/customization-profiles`
- Nav: **Cluster → Customization Profiles**
- Related: `/vm-setup`, `/vms`, `/templates`

## Operate from the console (UX)

1. Open `/customization-profiles` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Reusable guest customization specs — cloud-init, Windows sysprep/unattend XML, and SSH authorized keys — applied from cr….
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Reusable guest customization specs — cloud-init, Windows sysprep/unattend XML, and SSH authorized ke.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VM setup](../core/vm-setup.md)
- [VMs](../core/vms.md)
- [Templates](./templates.md)
