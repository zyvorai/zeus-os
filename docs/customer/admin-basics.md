# Admin Basics (Customer Deployments)

Platform-facing configuration for Zeus OS. Operators using the UI day-to-day can skip this unless asked to verify URL, TLS, or auth.

For the full env-var and production checklist, see [Handbook — Administration & Configuration](../handbook/admin-configuration.md).

## Ports customers care about

| Port | Service | Typical use |
|------|---------|-------------|
| **5050** | `zeus-os-web` | Direct / local dashboard + API |
| **30050** | NodePort (common deploy) | Cluster-exposed HTTPS dashboard |
| **8081** | Optional console-proxy | Sidecar console proxy |
| **9191 / 9443** | PacketWolf | Network intelligence (proxied) |
| **9090** | Prometheus | Metrics source (cluster) |

Zeus itself listens on **5050** (plus optional console proxy). Give customers the **ingress or NodePort URL**, not internal ClusterIP addresses.

## Fastest production-style deploy

```bash
# On a machine with kubeconfig + KubeVirt already installed
./scripts/deploy-remote.sh <HOST> <SSH_USER> --k3s
# → https://<HOST>:30050
```

Air-gapped: [AIR_GAPPED_INSTALL.md](../AIR_GAPPED_INSTALL.md). Helm profiles: [HELM_VALUES_PROFILES.md](../HELM_VALUES_PROFILES.md).

### From a binary bundle (no git clone, no build tools)

If you received a `zeus-os-<version>-linux-amd64.tar.gz` bundle (built via
`scripts/package-binary-remote.sh`), it ships the Helm chart plus a script that builds a
runtime image from the bundle's own binaries — no source tree, no cargo/npm:

```bash
tar xzf zeus-os-*-linux-amd64.tar.gz && cd zeus-os-*-linux-amd64
./install-cluster.sh                                          # KubeVirt/CDI/Cilium prereqs
./install-to-kubernetes.sh --registry <your-registry>/zeus-os --push
./apply-cluster-network.sh
```

`install-to-kubernetes.sh --help` shows namespace/release/dry-run options, and a local
single-node cluster (kind/k3s/minikube) sharing the build daemon's image store can skip
`--push` entirely. Note: an image built this way lacks the `helm` CLI the full-source
`web/Dockerfile` bundles — the in-app /helm repo/install UI won't work; use `web/Dockerfile`
instead if you need it. Browser-VNC assets and GuestKit agent binaries are included.

## Authentication (what to enable)

Resolution order on the server:

1. `ZEUS_OS_NO_AUTH=1` — lab only
2. `ZEUS_OS_API_KEY` — static bearer for API
3. `ZEUS_OS_AUTH=local|ldap|saml|oidc` — interactive login

Enterprise detail: [ENTERPRISE_AUTH_TENANCY.md](../ENTERPRISE_AUTH_TENANCY.md).

When `ldap`/`saml`/`oidc` is set, the local admin account stays available as a break-glass
fallback automatically — the login screen shows an explicit toggle to pick between the directory/
SSO method and the local admin account, rather than requiring the operator to know a hidden URL.

**Tell operators:**

- Dashboard URL + auth method
- Whether MFA / SSO is required
- That RDP/SSH use **guest** credentials

### Local admin password

The built-in local admin account defaults to **`Admin@321`** when `ZEUS_OS_LOCAL_ADMIN_PASSWORD`
isn't set — **change this before any internet-facing or production install.**

The default differs by install path:

| Install path | Default behavior |
|--------------|-------------------|
| Helm chart | Fixed `Admin@321` unless `config.localAuth.adminPassword` or `config.localAuth.adminPasswordSecretRef` is set in `values.yaml` |
| Binary bundle (`scripts/package-binary-remote.sh`) | Generates a **random** strong password automatically unless `ZEUS_OS_LOCAL_ADMIN_PASSWORD` is set in the bundle's env file — does **not** fall back to `Admin@321` |

Set your own password at install time (Helm):

```bash
helm upgrade --install zeus-os ./chart --set config.localAuth.adminPassword="a-real-password"
# or reference an existing Secret instead of inlining the password:
# --set config.localAuth.adminPasswordSecretRef.name=zeus-os-local-auth
```

## TLS (required for browser VNC)

```bash
export ZEUS_OS_TLS_CERT=/path/to/cert.pem
export ZEUS_OS_TLS_KEY=/path/to/key.pem
# or terminate TLS at ingress and serve the SPA behind HTTPS
```

Without a secure context, in-browser VNC will not work; serial console still can.

## Multi-tenancy

Namespaces may be labeled `zeus-os.io/tenant=<id>`. List APIs filter by tenant for scoped users. Configure tenants under **Tenancy** (`/tenancy`) and Identity Center.

## What to hand customers after install

1. Correct HTTPS URL (and the port that is *not* GuestKit/Machina).
2. Login instructions for your auth mode.
3. Link to this customer package: `docs/customer/README.md` (or the PDF set).
4. Optional: Feature Guide PDF for capability overview.

## Health checks

```bash
curl -sk -o /dev/null -w "%{http_code}\n" https://<host>:30050/api/v1/health
kubectl -n zeus-os get pods,svc   # namespace may differ per chart
```

## Related

- [Getting Started](getting-started.md) — operator path after URL works
- [Enterprise SSO / OIDC](enterprise-sso.md) — Keycloak and generic OIDC
- [CUSTOMER_ACCESS_RUNBOOK.md](../CUSTOMER_ACCESS_RUNBOOK.md) — example access notes
- [Handbook README](../handbook/README.md)
