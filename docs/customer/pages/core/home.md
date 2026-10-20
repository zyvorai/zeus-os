# Home (Mission Control)

## Purpose

Apple.com-style chapter home: greeting hero, **Get the highlights** (fleet KPIs on a dark band), infrastructure pulse, a light Attention teaser, running machines, and apps/insights — without the heavy triage deck.

## When to use it

- Start of shift — “is the platform healthy?”
- Jump to Machine Runway, Attention, Health, or Incidents from localnav
- Spot open issues via the Attention teaser, then open `/attention` for actions and Issue Stream

## How to get there

- Route: `/`
- Nav: **Home** · workspace **Dashboard**

## Operate from the console (UX)

1. Open `/` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the hero (greeting + fleet summary) and localnav: **Machines · Attention · Health · Incidents · Create**.
3. Scan **Get the highlights**, then **Infrastructure pulse**, then the light **What needs you next** teaser — use **Open Attention** for ranked actions and Issue Stream (not embedded on Home).
4. Browse **Running machines** and **Apps and insights** chapters.
5. Open **Getting started checklist** (Help → Getting Started) if you are new — progress is saved to your account.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed.
7. **Success:** You can reach Attention, VMs, or Health without hunting the full sidebar.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.

## Related pages

- [Attention](../observe/attention.md) — `/attention`
- [Virtual Machines](vms.md) — `/vms`
- [System Health](../observe/system-health.md) — `/system-health`
- [Incidents](../observe/incidents.md) — `/incidents`
- [Capacity](../../PAGE_INDEX.md) — `/capacity`
