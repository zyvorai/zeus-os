# Settings — Appearance

## Purpose

Control how the Zeus OS shell looks and behaves: Light or Dark theme, wallpaper, glass and motion effects, sidebar mode, and the dock.

## When to use it

- Switch between **Light** (Tahoe paper + Action Blue) and **Dark** (Netra carbon)
- Use the sun/moon control in the menubar or WebShell header for the same flip
- Reduce motion or glass effects on lower-powered machines
- Collapse the sidebar to an icon rail for more screen space
- Pin the centers you use most to the dock and Finder favourites

## How to get there

- Route: `/settings/appearance`
- Nav: **Settings → Appearance**
- Quick toggle: circular sun/moon button in the Mac menubar or Web page header

## Themes (Light / Dark only)

| Appearance | Store id | Look |
|------------|----------|------|
| **Light** | `tahoe-light` | Quiet Apple paper (`#f5f5f7`), ink `#1d1d1f`, Action Blue CTAs |
| **Dark** | `zyvor-carbon` | Near-black page (`#000`), elevated `#1d1d1f`, Action Blue intent |

Older exotic shells (Aurora, Predator, Dark steel, Zinc metal, Emerald Noir, Nova, Classic Blue) are removed. Stored values migrate to Dark on next load.

Zyvor branding: bare orange **Z** in chrome; filled orange tile on the login page and favicon (`#ff5a15` → `#cc420a`). Brand orange is for the Z mark — interactive chrome uses Action Blue.

## Operate from the console (UX)

1. Open `/settings/appearance` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Choose **Light** or **Dark** — the shell updates immediately (also via the sun/moon toggle).
3. Change only the section you need next (wallpaper, glass intensity, sidebar, dock).
4. Save; API keys and SSO changes may require re-login.
5. Cluster-wide TLS/auth/data-dir remain server env — see Admin basics.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.

## Related pages

- [Settings overview](./settings.md)
- [Using the Dashboard](../../using-the-dashboard.md)
- [Liquid Glass design system](../../../liquid-glass-design-system.md)
- [Favorites](../core/favorites.md)
