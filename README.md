# Zeus OS

Visual control plane for KubeVirt virtual machines and Kubernetes infrastructure:
web dashboard, TUI, CLI and REST/WebSocket API.

This repository distributes **binaries, container images, the Helm chart and documentation**.
It contains no source code.

- Docs: https://zyvorai.github.io/zeus-os/
- Releases: https://github.com/zyvorai/zeus-os/releases

## Install

```bash
# Container
docker run -p 5050:5050 ghcr.io/zyvorai/zeus-os-web:latest

# Helm
helm install zeus-os oci://ghcr.io/zyvorai/charts/zeus-os --version <version>

# Binary (Linux amd64/arm64)
curl -LO https://github.com/zyvorai/zeus-os/releases/download/v<version>/zeus-os-<version>-linux-amd64.tar.gz
```

## Verify

```bash
sha256sum -c SHA256SUMS
cosign verify ghcr.io/zyvorai/zeus-os-web:<version> \
  --certificate-identity-regexp 'https://github.com/.*/zeus-os/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

Licensed under the Zeus OS EULA (see `LICENSE`). Security reports: `SECURITY.md`.
