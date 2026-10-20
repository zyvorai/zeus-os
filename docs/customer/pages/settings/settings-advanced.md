# Settings — Advanced

## Purpose

Shortcuts into platform, debug, and developer tooling, plus keyboard shortcuts and build information.

## When to use it

- Collect diagnostics for a support case
- Reach debug and developer tools without memorizing routes
- Look up keyboard shortcuts
- Check the About panel for build details

## How to get there

- Route: `/settings/advanced`
- Nav: **Settings → Advanced**
- Related: `/debug`, `/kernel`, `/api-docs`, `/shortcuts`

## Operate from the console (UX)

1. Open `/settings/advanced` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Shortcuts into platform, debug, and developer tooling, plus keyboard shortcuts and build information.
3. Change only the section you need (General / Appearance / Advanced / API access / …).
4. Save; API keys and SSO changes may require re-login.
5. Cluster-wide TLS/auth/data-dir remain server env — see Admin basics.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Shortcuts into platform, debug, and developer tooling, plus keyboard shortcuts and build information.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Settings overview](./settings.md)
- [Debug](../more/debug.md)
- [Kernel Info](../more/kernel.md)
- [Support](../centers/support.md)
