# Attention

## Purpose

Ranked next steps, live fleet signals (Issue Stream), and day-2 remediation activity — the triage surface that used to live as a heavy block on Home.

## When to use it

- Start of shift when Home shows warnings or error VMs
- Follow AI-ranked recommended actions (guest agent, unhealthy workloads, alerts)
- Watch the live Issue Stream and day-2 playbook activity without cluttering Home

## How to get there

- Route: `/attention`
- Nav: **Observe → Attention** · Home localnav **Attention** · Home CTA **Open Attention**
- Related: `/incidents`, `/system-health`, `/events`, `/ai-center`

## Operate from the console (UX)

1. Open `/attention` from Home (**Open Attention**), Observe nav, or command palette (⌘K / Ctrl+K).
2. Use the chapter localnav (brand left, **Home · Health · Incidents · Event log** spaced on the right) to jump between triage lenses.
3. Scan **Get the highlights**, then **Recommended actions** — P1/P2 cards with CTAs into VM Guest Tools, Incidents, or System Health.
4. Use **Issue Stream** (ink chapter + Replay window) for live Warning/Normal fleet events; open **Event log** for the full stream.
5. Review **Day-2 activity** for closed-loop remediation status.
6. Jump to **Incidents** when correlation or collaboration is needed, or **System Health** for host/vitality lenses.
7. **Empty / fail:** No actions → fleet is quiet; Ask Zyra or System Health for a deeper scan. No events → widen Replay or check Events.
8. **Success:** You can act on a ranked item or open a related center without returning to Home for the heavy deck.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.

## Related pages

- [Home](../core/home.md) — `/`
- [Incidents](./incidents.md) — `/incidents`
- [System Health](./system-health.md) — `/system-health`
- [Events](./events.md) — `/events`
