# Mesh Detail

## Purpose

Legacy nav entry for service-mesh detail. The dashboard redirects this route to **Service Mesh**, the Multus NAD and VM attachment inventory.

## When to use it

- Same jobs as Service Mesh (NAD inventory, VM attachments)
- Following older bookmarks or docs that cite `/service-mesh-detail`
- Cross-linking from Network Flow investigations

## How to get there

- Route: `/service-mesh-detail` (redirects to `/service-mesh`)
- Nav: **More → Mesh & traffic → Mesh Detail**
- Related: `/service-mesh`, `/network-flow`, `/cilium`

## Operate from the console (UX)

1. Open `/service-mesh-detail` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Legacy nav entry for service-mesh detail. The dashboard redirects this route to **Service Mesh**, the Multus NAD and VM ….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Legacy nav entry for service-mesh detail. The dashboard redirects this route to **Service Mesh**, th.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Network Flow](./network-flow.md)
- [Cilium CNI](./cilium.md)
- [Network attachments](../cluster/network-attachments.md)
