# AutoScaler

## Purpose

Define policies that resize VMs automatically, and review right-sizing recommendations with their estimated monthly cost impact before applying them.

## When to use it

- Create a CPU/memory scaling policy for a namespace, label set, or all VMs
- Apply a right-sizing recommendation to an over- or under-provisioned VM
- Check whether recent automatic scaling events succeeded
- Estimate monthly savings available from resizing

## How to get there

- Route: `/autoscaler`
- Nav: **Run -> AutoScaler**
- Related: `/cluster-autoscaling`, `/optimization`, `/vms`

## Operate from the console (UX)

1. Open `/autoscaler` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Define policies that resize VMs automatically, and review right-sizing recommendations with their estimated monthly cost….
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Define policies that resize VMs automatically, and review right-sizing recommendations with their es.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Cluster Autoscale](./cluster-autoscaling.md)
- [VMs](../core/vms.md)
- [VM Workbench](../core/vm-workbench.md)
- [Operations](./operations.md)
