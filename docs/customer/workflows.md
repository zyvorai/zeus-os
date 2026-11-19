# Common workflows

End-to-end jobs that span multiple pages. Use with the [page guides](pages/README.md).

## Start-of-shift triage

1. [Home](pages/core/home.md) — scan pulse and the Attention teaser
2. [Attention](pages/observe/attention.md) — ranked actions, Issue Stream, day-2 activity
3. [Incidents](pages/observe/incidents.md) or [System Health](pages/observe/system-health.md) — drill down when correlation or host health is needed
4. [VMs](pages/core/vms.md) — act on VM-scoped recommended actions (guest agent, power, console)

## Create → console → snapshot

1. [VM setup](pages/core/vm-setup.md) — `/vm-setup`
2. Wait until status is Running on [VMs](pages/core/vms.md)
3. Open [workbench](pages/core/vm-workbench.md) → [Console](pages/consoles/overview.md)
4. Before changes: [Snapshots](pages/run/snapshots.md)

## Maintain a node

1. [Nodes](pages/cluster/nodes.md) — identify the node
2. [Live Migrations](pages/run/migrations.md) — evacuate VMs (dry-run first)
3. Node Drain — `/node-drain`
4. Confirm [VM Instances](pages/core/vmis.md) on remaining workers

## Contain a noisy or compromised VM

1. [Incidents](pages/observe/incidents.md) — open or create context
2. [PacketWolf](pages/more/packetwolf.md) — dry-run then apply containment
3. [Console](pages/consoles/overview.md) — inspect guest if needed
4. Remove containment when resolved

## Cost waste sweep

1. [Cost Intelligence](pages/cost/cost-intelligence.md)
2. [Rightsizing](pages/cost/rightsizing.md)
3. Apply safer shapes via workbench / [instance types](pages/core/instance-types.md)
4. Re-check spend after metrics catch up

## Backup before upgrade

1. [Snapshot Manager](pages/run/snapshots.md) and/or [Velero](pages/run/velero.md)
2. [Backup Wizard](pages/run/backup-wizard.md) if you want a guided checklist
3. Perform change
4. Restore Wizard `/restore-wizard` only if needed

## Related

- [Getting Started](getting-started.md)
- [Feature Guide](../zeus-os-customer-feature-guide.md)
