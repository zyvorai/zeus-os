# PacketWolf VM Guard

## Purpose

Network intelligence and VM Shield containment — see allowed/denied flows and apply quarantine / internet-lock profiles (typically Cilium/Hubble backed).

## When to use it

- Investigate unexpected egress/ingress for a VM
- Contain a compromised or noisy workload quickly
- Preview a policy as dry-run before enforce

## How to get there

- Route: `/packetwolf`
- Nav: **More → Mesh & traffic → PacketWolf VM Guard**
- Related: `/network-flow`, `/network-flow?tab=firewall`, `/cilium`

## Operate from the console (UX)

1. Open `/packetwolf` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Network intelligence and VM Shield containment — see allowed/denied flows and apply quarantine / internet-lock profiles ….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Network intelligence and VM Shield containment — see allowed/denied flows and apply quarantine / int.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Network Flow](../../PAGE_INDEX.md) — `/network-flow`
- [Security](../security/security.md)
- [Incidents](../observe/incidents.md)
- Deep dive: [PACKETWOLF_VM_SHIELD.md](../../../PACKETWOLF_VM_SHIELD.md)
