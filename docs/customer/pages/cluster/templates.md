# Templates

## Purpose

Curated VM templates for one-click or guided deploy of known-good shapes.

## When to use it

- Standard golden images / org templates
- Faster create than blank instance-type only
- Hand off approved configs to app teams
- Windows Kryton catalog templates (`windows-11-enterprise`, `windows-server-2025`, …) when Kryton is Connected

## How to get there

- Route: `/templates`
- Nav: **Cluster → Templates**
- Related: [Windows via Kryton](./windows-via-kryton.md)

## Operate from the console (UX)

1. Open `/templates` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Filter Windows / Linux; Kryton-tagged Windows templates prefill the wizard with `windowsInstall=kryton`.
3. Use namespace / label filters; open an object for inspector details.
4. Deploy / prefill; wait for toast + inventory refresh.
5. **Empty / fail:** Check auth and catalog; for Kryton Windows also Settings → Network → Kryton (`GET /api/v1/kryton/status`).

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.

## Related pages

- [Windows via Kryton](./windows-via-kryton.md)
- [VM setup](../core/vm-setup.md)
- [Image Factory](./image-factory.md)
- [Customization Profiles](../../PAGE_INDEX.md) — `/customization-profiles`
- [Blueprints](../../PAGE_INDEX.md) — `/blueprints`
