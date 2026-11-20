# Admission control

## Purpose

Read-only inventory of what intercepts writes to your cluster: validating and mutating admission webhooks, Kyverno policy rules, webhook statistics, and recent admission-related events.

## When to use it

- Find out which webhook is rejecting a create or update
- Check a webhook's failure policy before taking its backing service down
- Confirm Kyverno policies are installed and ready
- Review recent admission events during an incident

## How to get there

- Route: `/admission-control` (the active tab is kept in the `?tab=` query parameter)
- Nav: **Security -> Admission Control**
- Related: `/opa`, `/security`, `/compliance`

## Operate from the console (UX)

1. Open `/admission-control` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Read-only inventory of what intercepts writes to your cluster: validating and mutating admission webhooks, Kyverno polic….
3. Scan health cards and shortcuts into VMs, incidents, capacity, and consoles.
4. Open **Getting started checklist** (Help → Getting Started) if you are new — progress is saved to your account.
5. Use workspace switcher: Dashboard · VMs · Kubernetes · AI · Storage · Monitoring.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Read-only inventory of what intercepts writes to your cluster: validating and mutating admission web.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [OPA Gatekeeper](./opa.md)
- [Security](./security.md)
- [Image Scanning](./image-scanning.md)
- [Compliance](./compliance.md)
