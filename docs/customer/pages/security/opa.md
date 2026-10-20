# OPA Gatekeeper

## Purpose

Read-only inventory of your OPA Gatekeeper constraints and constraint templates, with the current violation count and the offending resources behind each one.

## When to use it

- See which Gatekeeper constraints are actively denying and which are in dry-run
- Find the exact pods breaching a policy before you enforce it
- Confirm a new ConstraintTemplate rolled out and has constraints bound to it
- Report total policy violations during a security review

## How to get there

- Route: `/opa`
- Nav: **Security -> OPA Gatekeeper**
- Related: `/admission-control`, `/security`, `/compliance`

## Operate from the console (UX)

1. Open `/opa` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only inventory of your OPA Gatekeeper constraints and constraint templates, with the current violation count and th….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only inventory of your OPA Gatekeeper constraints and constraint templates, with the current vi.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Admission Control](./admission-control.md)
- [Security](./security.md)
- [Compliance](./compliance.md)
- [Network hub (Policy builder tab)](../more/network-flow.md)
