# Workflows

## Purpose

Read-only view of the automation workflows registered with Zeus OS: what is scheduled, when each last ran, how reliable it has been, and the template gallery you can copy from.

## When to use it

- Check whether a nightly automation ran and succeeded
- Find a workflow whose success rate has dropped
- See what is scheduled to run next
- Browse the template gallery before authoring a new workflow

## How to get there

- Route: `/workflows`
- Nav: **Run -> Workflows**
- Related: `/events?tab=scheduled`, `/operations`, `/cicd`

## Operate from the console (UX)

1. Open `/workflows` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only view of the automation workflows registered with Zeus OS: what is scheduled, when each last ran, how reliable ….
3. Prefer dry-run / plan when the UI offers it before mutating production.
4. Start the wizard or job; watch progress and history panels.
5. Confirm completion on the target inventory (VMs, snapshots, backup store).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only view of the automation workflows registered with Zeus OS: what is scheduled, when each las.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Events (Scheduled ops tab)](../observe/events.md)
- [Operations](./operations.md)
- [Change Approval](../security/change-approval.md)
