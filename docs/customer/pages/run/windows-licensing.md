# Windows Licensing

## Purpose

Read-only inventory of Windows activation state across your KubeVirt VMs, collected through the guest agent (`slmgr`). Zeus OS never hosts a KMS or redistributes licenses — it reports what your own activation infrastructure says.

## When to use it

- Confirm every Windows guest is activated before an audit
- Find VMs sitting in a grace period or about to expire
- Verify newly provisioned Windows VMs picked up the right KMS host
- Spot guests where the agent is offline, so licensing state is unknown

## How to get there

- Route: `/windows-licensing`
- Nav: **Run -> Windows Licensing**
- Related: `/vms`, `/compliance`

## Operate from the console (UX)

1. Open `/windows-licensing` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only inventory of Windows activation state across your KubeVirt VMs, collected through the guest agent (`slmgr`). Z….
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only inventory of Windows activation state across your KubeVirt VMs, collected through the gues.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [VMs](../core/vms.md)
- [VM Workbench](../core/vm-workbench.md)
- [Compliance](../security/compliance.md)
- [Security](../security/security.md)
