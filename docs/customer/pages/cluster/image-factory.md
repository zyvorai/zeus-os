# Image Factory

## Purpose

Golden Image Factory pipelines that take a customer-supplied OS ISO through VirtIO, updates, optional GuestKit bake, sysprep/generalize, snapshot, and catalog publish.

When **Kryton** is Connected (Settings → Network), the same page also offers **Build with Kryton**: live Kryton catalog → dockur golden → CDI bootstrap, without embedding Kryton’s UI.

## When to use it

- Build a Windows or Ubuntu golden template from an ISO URL (Zeus pipeline)
- Prefer **Build with Kryton** for Windows dockur catalog images when Kryton is healthy
- Track pipeline / golden progress; **Advance** Zeus pipelines when the next stage is ready
- Bake the GuestKit agent into Zeus-pipeline images before publish

## How to get there

- Route: `/image-factory`
- Nav: **Cluster → Image Factory**
- Related: `/blueprints`, `/templates`, `/image-library`, [Windows via Kryton](./windows-via-kryton.md)

## Operate from the console (UX)

1. Open `/image-factory` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. If Kryton is Connected: pick a Kryton catalog image → **Build with Kryton**; poll golden status on the page (or via `/api/v1/kryton/golden`).
3. For Zeus ISO pipelines: create/advance pipelines as before (VirtIO → publish).
4. Mutations go through confirm sheets — wait for status refresh.
5. **Empty / fail:** No data → check auth, namespace filter, KubeVirt/CDI; for Kryton builds also check Settings → Network → Kryton and `GET /api/v1/kryton/status`.
6. **Success:** Live inventory or job progress matches the deck; related centers open without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.

## Related pages

- [Windows via Kryton](./windows-via-kryton.md)
- [Blueprints](./blueprints.md)
- [Templates](./templates.md)
- [Image Library](./image-library.md)
- [Image Registry](./image-registry.md)
