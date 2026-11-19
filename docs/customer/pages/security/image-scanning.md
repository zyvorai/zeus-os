# Image Scanning

## Purpose

Vulnerability posture for your container and VM images: critical, high, medium, and low counts per image, when each was last scanned, and the scan policies that decide pass or fail.

## When to use it

- Check whether any image in use carries a critical CVE
- Find images that have not been rescanned recently
- See which scan policy blocks and which only warns
- Gather image risk evidence for a security review

## How to get there

- Route: `/image-scanning`
- Nav: **Security -> Image Scanning**
- Related: `/security`, `/compliance`, `/admission-control`

## Operate from the console (UX)

1. Open `/image-scanning` from the sidebar, workspace switcher, or command palette (⌘K / Ctrl+K).
2. Read the PageHead / deck line — confirm it matches: Vulnerability posture for your container and VM images: critical, high, medium, and low counts per image, when each was ….
3. Filter findings / policies by severity or namespace.
4. Open a row for evidence and remediation; use change-approval gates when enabled.
5. Export or acknowledge as your role allows — do not mute crit without a live condition handled.
6. **Empty / fail:** No data → check auth, namespace filter, and that required operators (KubeVirt/CDI/monitoring) are installed; purpose was: Vulnerability posture for your container and VM images: critical, high, medium, and low counts per i.
7. **Success:** Live inventory or job progress matches the deck line; you can navigate to a related center without re-auth.

Use `https://<host>:30050/` (NodePort) or your ingress URL — never publish lab IPs. HTTPS is required for in-browser VNC. Browse lists are safe; power actions live on workbenches.


## Related pages

- [Security](./security.md)
- [Admission Control](./admission-control.md)
- [Compliance](./compliance.md)
- [OPA Gatekeeper](./opa.md)
