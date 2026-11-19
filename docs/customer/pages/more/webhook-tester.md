# Webhook Tester

## Purpose

Validate alert webhook delivery: test configured alert webhooks or POST a custom payload to any URL and inspect latency and response.

## When to use it

- Prove an alert channel receives events before go-live
- Debug failed webhook deliveries with status and body
- Fire a one-off manual POST to a Slack/HTTP endpoint
- Refresh the list of configured alert webhooks

## How to get there

- Route: `/webhook-tester`
- Nav: **More → Tools & settings → Webhook Tester**
- Related: `/alerting?tab=channels`, `/alerting`, `/api-playground`

## Operate from the console (UX)

1. Open `/webhook-tester` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Validate alert webhook delivery: test configured alert webhooks or POST a custom payload to any URL and inspect latency ….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Validate alert webhook delivery: test configured alert webhooks or POST a custom payload to any URL .
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Alerting (Channels tab)](../observe/alerting.md)
- [API Playground](./api-playground.md)
- [Status Page](./status-page.md)
- [Alerting](../../PAGE_INDEX.md) — `/alerting`

