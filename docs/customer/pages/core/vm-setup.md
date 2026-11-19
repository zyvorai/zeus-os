# VM setup (create a machine)

## Purpose

Guided creation of a new KubeVirt VM from instance types, preferences, templates, or AI-assisted manifests.

## When to use it

- Provision a new workload VM without writing YAML
- Standardize on catalog shapes (instance types)
- Clone-like create from a template or blueprint
- Create **Windows** via Kryton catalog when Settings → Network shows Kryton Connected
  (otherwise Autounattend / ISO / Zeus golden PVC)

## How to get there

- Routes: `/vm-setup`, `/vms/new` (and Create Machine sheet flows)
- Nav: **Core → VM setup** · shortcut from VMs inventory

## Operate from the console (UX)

1. Open `/vm-setup` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Pick Linux or Windows. For Windows with Kryton Connected: choose a Kryton catalog image
   (e.g. `windows-11-enterprise`) — Zeus posts to `/api/v1/kryton/machines`.
3. Review disks, network, and namespace; deploy.
4. Confirm success via toast + refreshed inventory; Kryton VMs open at `/vms/{ns}/{name}` from `providerRef`.
5. **Empty / fail:** Check auth, namespace, KubeVirt/CDI; for Kryton also `GET /api/v1/kryton/status`.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.

## Related pages

- [Windows via Kryton](../cluster/windows-via-kryton.md)
- [Instance types](instance-types.md)
- [Templates](../cluster/templates.md)
- [Virtual Machines](vms.md)
- [DataVolumes](../cluster/datavolumes.md)
- [Image Factory](../cluster/image-factory.md)
