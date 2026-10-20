# Resource Tags

## Purpose

Tag coverage and compliance for cluster resources: distribution of keys, untagged inventory, required-tag checks, and bulk apply.

## When to use it

- Measure how many resources carry FinOps or ownership tags
- Find untagged workloads missing required keys
- Enforce tagging policy checks before chargeback
- Bulk-apply a key/value to a namespace

## How to get there

- Route: `/resource-tagging`
- Nav: **More → Tools & settings → Resource Tags**
- Related: `/cost-allocation`, `/tenancy`, `/vms`

## Operate from the console (UX)

1. Open `/resource-tagging` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Tag coverage and compliance for cluster resources: distribution of keys, untagged inventory, required-tag checks, and bu….
3. Use the center’s primary CTA (create, scan, open workbench, ask Zeus when reasoning is required).
4. Deterministic navigation and filters call the router directly — do not round-trip those through Ask Zeus.
5. Pin frequent pages to Favorites (`/favorites`).
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Tag coverage and compliance for cluster resources: distribution of keys, untagged inventory, require.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Cost Allocation](../cost/cost-allocation.md)
- [Virtual Machines](../core/vms.md)
- [Settings](../settings/settings.md)
- [Tenancy](../../PAGE_INDEX.md) — `/tenancy`

