# Settings — General

## Purpose

Server information and dashboard-wide preferences: what build you are running and how lists and cards behave for your account.

## When to use it

- Confirm the Zeus OS version and server details before raising a support case
- Toggle dashboard preferences such as health scores on inventory cards
- Verify you are pointed at the expected cluster/server

## How to get there

- Route: `/settings/general`
- Nav: **Settings → General**
- Related: `/settings/appearance`, `/settings/advanced`

## Operate from the console (UX)

1. Open `/settings/general` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the editorial intro (eyebrow **Settings**), then confirm hostname / OS / kernel, and adjust dashboard refresh if needed.
3. Change only the section you need (General / Appearance / Advanced / API access / …).
4. Save; API keys and SSO changes may require re-login.
5. Cluster-wide TLS/auth/data-dir remain server env — see Admin basics.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Server information and dashboard-wide preferences: what build you are running and how lists and card.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Settings overview](./settings.md)
- [Settings — Appearance](./settings-appearance.md)
- [Settings — Advanced](./settings-advanced.md)
- [Support](../centers/support.md)
