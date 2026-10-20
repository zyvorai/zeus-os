<p align="center"><img src="docs-assets/banner.svg" alt="Zeus OS: every VM, one control plane" width="100%"></p>

<p align="center">
  <a href="https://zyvorai.github.io/zeus-os/"><b>Website</b></a> ·
  <a href="https://zyvorai.github.io/zeus-os/docs/"><b>Documentation</b></a> ·
  <a href="https://github.com/zyvorai/zeus-os/releases"><b>Releases</b></a> ·
  <a href="SECURITY.md"><b>Security</b></a>
</p>

<h3 align="center">The visual control plane for KubeVirt virtual machines and Kubernetes.</h3>

<p align="center">Create, run, migrate, secure and cost every VM from a web dashboard, a terminal UI, a CLI or an API. One engine, four interfaces, so they always agree.</p>

> **This repository distributes binaries, container images, the Helm chart and documentation. It contains no source code.**
> No public release has been published yet. The install commands below apply once the first release is out; watch [Releases](https://github.com/zyvorai/zeus-os/releases).

## What you get

| | |
|---|---|
| **KubeVirt-native** | Uses CRDs and subresources instead of shelling out, so what you see is what the cluster is doing. |
| **Four interfaces** | Web dashboard, terminal UI (48+ views), headless CLI, REST and WebSocket API. |
| **Consoles** | VNC and serial in the browser; native RDP and SSH through your own client. |
| **Live migration and DRS** | Move running VMs between nodes and let auto-rebalance keep clusters level, with cooldowns and an audit trail. |
| **Multi-tenant** | Tenant-scoped views, quotas and RBAC across lists and actions. |
| **Identity** | Local, LDAP, SAML and OIDC sign-in, SCIM v2 provisioning, WebAuthn second factor. |
| **FinOps** | One price model across every cost page, measured cost history, budgets, dry-run-first waste cleanup. |
| **Day-2 operations** | Remediation playbooks, snapshot and power schedules, backups, with a kill-switch on every engine. |
| **Networking** | Flow, DNS and security-group views, zero-trust namespace isolation, Cilium egress, BGP and Gateway API. |
| **Ask Zyra** | An assistant that answers from your cluster and your own docs, with citations. |

Zeus OS says so when something is a preview: unknown values are shown as unknown, never as zero. Check the [documentation](https://zyvorai.github.io/zeus-os/docs/) for the status of each feature.

## Install

```bash
# Container
docker run -p 5050:5050 ghcr.io/zyvorai/zeus-os-web:latest

# Kubernetes (Helm, OCI)
helm install zeus-os oci://ghcr.io/zyvorai/charts/zeus-os --version <version>

# Binary (Linux amd64 / arm64)
curl -LO https://github.com/zyvorai/zeus-os/releases/download/v<version>/zeus-os-<version>-linux-amd64.tar.gz
```

Authentication is on by default. For a local trial only, run with `ZEUS_OS_NO_AUTH=1`.

## Verify what you download

```bash
sha256sum -c SHA256SUMS
cosign verify ghcr.io/zyvorai/zeus-os-web:<version> \
  --certificate-identity-regexp 'https://github.com/.*/zeus-os/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

## Documentation

[Getting started](docs/customer/getting-started.md) · [Using the dashboard](docs/customer/using-the-dashboard.md) · [Admin basics](docs/customer/admin-basics.md) · [Enterprise SSO](docs/customer/enterprise-sso.md) · [CLI](docs/cli.md) · [SCIM](docs/SCIM.md) · [WebAuthn](docs/WEBAUTHN.md) · [Air-gapped install](docs/AIR_GAPPED_INSTALL.md)

## Security

Report vulnerabilities privately to security@zyvor.dev. See [SECURITY.md](SECURITY.md).

## License

Licensed under the Zeus OS EULA. The licence text will be added before the first release.
