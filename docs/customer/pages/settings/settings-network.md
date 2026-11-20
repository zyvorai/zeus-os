# Settings — Network

## Purpose

Entry point for network-related configuration and the PacketWolf network-intelligence integration.

## When to use it

- Check whether PacketWolf is paired and reachable
- Jump to the network center after changing cluster networking
- Verify network integration before relying on flow data or containment

## How to get there

- Route: `/settings/network`
- Nav: **Settings → Network**
- Related: `/packetwolf`, `/network-flow`, `/network-info`

## Operate from the console (UX)

1. Open `/settings/network` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Entry point for network-related configuration and the PacketWolf network-intelligence integration.
3. Use namespace / label filters; open an object for inspector details.
4. Mutations (drain, resize PVC, attach NAD) go through confirm sheets — wait for status refresh.
5. If empty: broaden namespace filter, confirm RBAC, and that the cluster API is reachable.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Entry point for network-related configuration and the PacketWolf network-intelligence integration.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Settings overview](./settings.md)
- [PacketWolf VM Guard](../more/packetwolf.md)
- [Network Flow](../more/network-flow.md)
- [Admin basics](../../admin-basics.md)
