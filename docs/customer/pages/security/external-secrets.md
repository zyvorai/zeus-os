# External Secrets

## Purpose

Monitor the `ExternalSecret` and `SecretStore` resources that pull credentials from Vault, cloud secret managers, and other providers into Kubernetes — with sync, validate, and delete actions.

## When to use it

- Find an ExternalSecret stuck in a failed sync
- Force a refresh after rotating a secret in the upstream provider
- Validate an ExternalSecret's configuration before debugging further
- Confirm a SecretStore reached the Ready condition

## How to get there

- Route: `/external-secrets`
- Nav: **Security -> External Secrets**
- Related: `/certificates`, `/security`, `/settings`

## Operate from the console (UX)

1. Open `/external-secrets` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Monitor the `ExternalSecret` and `SecretStore` resources that pull credentials from Vault, cloud secret managers, and ot….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Monitor the `ExternalSecret` and `SecretStore` resources that pull credentials from Vault, cloud sec.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Certificates](./certificates.md)
- [Security](./security.md)
- [Users](./users.md)
- [Settings](../settings/settings.md)
