<div align="center">

<img src="docs-assets/banner.svg" alt="Zeus OS: every VM, one control plane" width="100%">

[![Docs](https://img.shields.io/badge/Docs-zyvorai.github.io%2Fzeus--os-0071e3)](https://zyvorai.github.io/zeus-os/)
[![Status](https://img.shields.io/badge/status-preview-orange)](#status)
[![KubeVirt](https://img.shields.io/badge/KubeVirt-native-2997ff)](#why-zeus-os)
[![Platforms](https://img.shields.io/badge/Linux-amd64%20%C2%B7%20arm64-30d158)](#install)
[![Auth](https://img.shields.io/badge/auth-OIDC%20%C2%B7%20SAML%20%C2%B7%20LDAP%20%C2%B7%20SCIM-bf5af2)](docs/customer/enterprise-sso.md)
[![Helm](https://img.shields.io/badge/Helm-OCI%20chart-0f1689?logo=helm&logoColor=white)](#install)
[![License](https://img.shields.io/badge/license-Zeus%20OS%20EULA-orange)](#license)

[![Documentation](https://img.shields.io/badge/Read_the_docs-0071e3?style=for-the-badge)](https://zyvorai.github.io/zeus-os/)
[![Quickstart](https://img.shields.io/badge/Quickstart-000000?style=for-the-badge)](#quickstart)
[![Releases](https://img.shields.io/badge/Releases-63e6be?style=for-the-badge)](https://github.com/zyvorai/zeus-os/releases)

### See every VM. Move it, secure it, cost it. From one place.

**The visual control plane for KubeVirt virtual machines and Kubernetes infrastructure.** A web dashboard, a terminal UI, a CLI and an API, all driven by one engine, so they always agree.

**KubeVirt-native** · **Four interfaces, one engine** · **Auth on by default** · **Multi-tenant** · **Honest about previews**

📖 **[Read the full docs](https://zyvorai.github.io/zeus-os/)**: getting started, admin basics, enterprise SSO and a page-by-page guide.

</div>

---

> **This repository distributes binaries, container images, the Helm chart and documentation. It contains no source code.**
> <a id="status"></a>**Status: preview.** No public release has been published yet, so the install commands below apply once the first release is out. Watch [Releases](https://github.com/zyvorai/zeus-os/releases). Where a feature is partial, the product and its docs say so.

## What it does

![Operate, Observe, Secure, Govern](docs-assets/capabilities.svg)

## Why Zeus OS

| When this happens... | Zeus OS gives you... |
|---|---|
| Running KubeVirt means living in `kubectl` and YAML | A visual VM command center, plus a terminal UI and CLI for the same operations |
| Nobody can say what a VM costs | One price model across every cost page, measured cost history, budgets and waste detection that starts as a dry run |
| Consoles are scattered across tools | VNC and serial in the browser, native RDP and SSH through your own client |
| You need to move a running VM or level a cluster | Live migration and DRS auto-rebalance with cooldowns and an audit trail |
| Different teams share one cluster | Tenant-scoped views, quotas and role-based access |
| Sign-in has to fit your identity provider | Local, LDAP, SAML and OIDC, SCIM v2 provisioning and WebAuthn security keys |
| Something is wrong and you do not know where to look | A ranked Attention feed, a cluster flight recorder (DVR), events and alerting |
| You want an assistant, not another chatbot | Ask Zyra answers from your cluster and your own docs, with citations; private code stays out of remote models unless you allow it |

Unknown values are shown as unknown, never as zero, and features that are only partly built carry a preview banner.

## How it fits together

![Zeus OS architecture](docs-assets/architecture.svg)

Zeus OS uses KubeVirt and CDI custom resources and subresources first, rather than shelling out to `virtctl`. Optional integrations (Velero backups, Cilium networking, PacketWolf and Netra network views, identity providers) are switched on when you configure them.

## Quickstart

> Available once the first release is published.

```bash
# Container
docker run -p 5050:5050 ghcr.io/zyvorai/zeus-os-web:latest

# Kubernetes (Helm, OCI)
helm install zeus-os oci://ghcr.io/zyvorai/charts/zeus-os --version <version>
```

Then open `http://localhost:5050` (or your service address) and sign in. Authentication is on by default; `ZEUS_OS_NO_AUTH=1` is for a local trial only. Requires a Kubernetes cluster with KubeVirt and a valid kubeconfig or in-cluster service account.

| Next | Read |
|---|---|
| First five workflows | [Getting started](docs/customer/getting-started.md) |
| Daily use | [Using the dashboard](docs/customer/using-the-dashboard.md) |
| Deploy URL, auth, TLS, ports | [Admin basics](docs/customer/admin-basics.md) |
| Single sign-on | [Enterprise SSO](docs/customer/enterprise-sso.md) |
| Air-gapped clusters | [Air-gapped install](docs/AIR_GAPPED_INSTALL.md) |

## Install

```bash
# Binary (Linux amd64 / arm64)
curl -LO https://github.com/zyvorai/zeus-os/releases/download/v<version>/zeus-os-<version>-linux-amd64.tar.gz
tar xzf zeus-os-<version>-linux-amd64.tar.gz
```

### Verify what you download

Every release is planned to ship with checksums, signatures and an SBOM.

```bash
sha256sum -c SHA256SUMS
cosign verify ghcr.io/zyvorai/zeus-os-web:<version> \
  --certificate-identity-regexp 'https://github.com/.*/zeus-os/.*' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

## Four interfaces

```bash
zeus-os                     # terminal UI, k9s-style, 48+ views
zeus-os-web                 # web dashboard and API on :5050
zeus-os-cli vm list         # headless CLI (see docs/cli.md); destructive commands need --yes
curl -H "Authorization: Bearer $TOKEN" https://zeus.example.com/api/v1/vms
```

See the [CLI reference](docs/cli.md) and the [API notes](docs/api/README.md). An OpenAPI spec, Python and Go SDKs, a Terraform provider and an Ansible collection are available for the product.

## Security and identity

- Authentication is on by default; local, LDAP, SAML and OIDC sign-in, plus [SCIM v2](docs/SCIM.md) provisioning and [WebAuthn](docs/WEBAUTHN.md) security keys.
- Role-based access with tenant scoping, and an audit trail on actions.
- Risky network changes use a preview-then-apply gate.
- Releases are planned to ship signed, with checksums and an SBOM.

Report vulnerabilities privately to **security@zyvor.dev**. See [SECURITY.md](SECURITY.md).

## Documentation

| Goal | Document |
|---|---|
| Customer docs, page by page | [docs/customer](docs/customer/README.md) |
| Getting started | [docs/customer/getting-started.md](docs/customer/getting-started.md) |
| Admin basics | [docs/customer/admin-basics.md](docs/customer/admin-basics.md) |
| Enterprise SSO | [docs/customer/enterprise-sso.md](docs/customer/enterprise-sso.md) |
| CLI | [docs/cli.md](docs/cli.md) |
| SCIM provisioning | [docs/SCIM.md](docs/SCIM.md) |
| WebAuthn | [docs/WEBAUTHN.md](docs/WEBAUTHN.md) |
| Air-gapped install | [docs/AIR_GAPPED_INSTALL.md](docs/AIR_GAPPED_INSTALL.md) |

## Part of the Zyvor platform

| Product | Role |
|---|---|
| **Zeus OS** | Cloud and KubeVirt control plane (this repo) |
| [**hypercluster**](https://github.com/zyvorai/hypercluster) | Kubernetes cluster lifecycle for bare metal and private cloud |
| [**machina**](https://github.com/zyvorai/zyvor-machina) | Private cloud on KVM |
| [**netra**](https://github.com/zyvorai/zyvor-netra) | eBPF network observability and emergency control |
| [**hermes / iris**](https://github.com/zyvorai/iris) | Application layer for Kubernetes |
| [**guestkit**](https://github.com/zyvorai/zyvor-guestkit) | VM disk inspection |

More at [zyvor.dev](https://zyvor.dev).

## License

Zeus OS is distributed under the Zeus OS EULA. The licence text will be added before the first release.

<div align="center"><sub>© ZYVORAI LABS PRIVATE LIMITED</sub></div>
