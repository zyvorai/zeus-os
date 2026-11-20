# Cluster onboarding

## Purpose

Guided preflight for a new Zeus OS cluster — platform readiness, Cilium status check, and cluster info — then links into core navigation.

## When to use it

- First login after install
- Verify API reachability and baseline CRDs
- Confirm networking (Cilium) and KubeVirt-oriented cluster info
- Hand off into VMs or Settings when checks pass

## How to get there

- Route: `/onboarding`
- Nav: **Command palette / deep link**
- Related: `/vms`, `/cilium`, `/settings`

## Operate from the console (UX)

1. Open `/onboarding` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Guided preflight for a new Zeus OS cluster — platform readiness, Cilium status check, and cluster info — then links into….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Guided preflight for a new Zeus OS cluster — platform readiness, Cilium status check, and cluster in.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Virtual Machines](../core/vms.md)
- [Settings](../settings/settings.md)
- [System Health](../observe/system-health.md)
