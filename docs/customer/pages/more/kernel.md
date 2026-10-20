# Kernel Info

## Purpose

Host hardware and OS inventory: hostname, kernel, CPU, BIOS, PCI devices, and memory modules for the Zeus OS node.

## When to use it

- Confirm kernel and OS version before a host upgrade
- Inventory PCI devices for passthrough or driver issues
- Check DIMM locator, size, type, and speed
- Capture architecture and CPU model for capacity planning

## How to get there

- Route: `/kernel`
- Nav: **More → Tools & settings → Kernel Info**
- Related: `/debug`, `/host`, `/system-health`

## Operate from the console (UX)

1. Open `/kernel` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Host hardware and OS inventory: hostname, kernel, CPU, BIOS, PCI devices, and memory modules for the Zeus OS node.
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Host hardware and OS inventory: hostname, kernel, CPU, BIOS, PCI devices, and memory modules for the.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Debug](./debug.md)
- [System Health](../observe/system-health.md)
- [Host Info](../../PAGE_INDEX.md) — `/host`
