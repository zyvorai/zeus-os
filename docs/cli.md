# zeus-os-cli

Headless command-line tool built on the same Rust library as the TUI and web server.

```bash
cargo build --release -p zeus-os-cli      # binary: zeus-os-cli
```

There are two kinds of commands.

| Kind | Commands | Talks to | Auth |
|------|----------|----------|------|
| Direct | `vm`, `snapshot`, `node`, `storage`, `guest` | the cluster, via your kubeconfig | your kubeconfig RBAC |
| REST | `backup`, `template`, `network`, `tenant` | a running `zeus-os-web` (`--server`) | bearer token; tenancy, RBAC and audit apply |

Every listing command accepts `-o table|json|yaml` (default `table`). `json`/`yaml` emit the
full objects; `table` is a summary view.

## Direct commands

Namespaced commands take `-n/--namespace` (default `default`; listings default to all namespaces).

```bash
zeus-os-cli vm list -n prod -o json
zeus-os-cli vm get web -n prod -o yaml
zeus-os-cli vm start|stop|restart web -n prod
zeus-os-cli vm pause|unpause|softreboot web -n prod       # need a running VMI
zeus-os-cli vm reset web -n prod --yes                    # hard reset (no guest flush)
zeus-os-cli vm clone web web-copy -n prod                 # same namespace, created stopped
zeus-os-cli vm migrate web -n prod                        # live migration; refuses if LiveMigratable=False
zeus-os-cli vm delete web -n prod --yes

zeus-os-cli vm templates                                  # local templates (~/.zeus-os/templates.json or built-ins)
zeus-os-cli vm create --template "Ubuntu 24.04 LTS" --name web -n prod
zeus-os-cli vm create -f vm.yaml -n prod                  # -f - reads stdin; -n must match metadata.namespace if set

zeus-os-cli vm console web -n prod                        # prints connection info only
zeus-os-cli vm vnc web -n prod --server https://zeus:30050
```

`vm console` / `vm vnc` do **not** open a session or spawn a viewer. They confirm the VMI exists
and print the KubeVirt subresource path (a WebSocket upgrade endpoint on the Kubernetes API
server) and, for VNC with `--server`, the Zeus web console URL.

```bash
zeus-os-cli snapshot list -n prod
zeus-os-cli snapshot create web -n prod --name pre-upgrade --quiesce
zeus-os-cli snapshot restore pre-upgrade --vm web -n prod --yes   # replaces the VM's disks
zeus-os-cli snapshot delete pre-upgrade -n prod --yes

zeus-os-cli node list
zeus-os-cli node cordon worker-1          # AFFECTS SCHEDULING: no new workloads land on it
zeus-os-cli node uncordon worker-1
zeus-os-cli node drain worker-1 --yes     # cordon + live-migrate KubeVirt VMs off the node

zeus-os-cli storage pvc list -n prod -o json
zeus-os-cli guest status web -n prod
```

`node drain` cordons the node and starts live migrations for the KubeVirt VMs running on it. It
does **not** evict ordinary pods, and the node stays cordoned afterwards (run `node uncordon`).
If some VMs cannot be migrated the command lists them and exits non-zero.

### Safety

- Destructive commands (`vm delete`, `vm reset`, `snapshot restore`, `snapshot delete`,
  `node drain`) require `--yes`. On a terminal without `--yes` you get a `y/N` prompt; with
  stdin not a terminal (scripts, CI) they refuse.
- The referenced VM/VMI/snapshot/node is verified to exist before anything is changed, and names
  are validated as Kubernetes names.
- Restoring a snapshot requires the snapshot to be `readyToUse`.

## REST commands

```bash
export ZEUS_OS_SERVER=https://zeus.example.com:30050
export ZEUS_OS_TOKEN=v9s_...              # preferred over --token (visible in `ps`)

zeus-os-cli backup list
zeus-os-cli backup create nightly -n prod -n dev --ttl-hours 168
zeus-os-cli backup restores
zeus-os-cli backup restore nightly --map prod=prod-copy
zeus-os-cli template list
zeus-os-cli template get small-linux -n zeus      # -n only needed if the name exists in several namespaces
zeus-os-cli network policies list -n prod
zeus-os-cli network attachments list
zeus-os-cli tenant list -o json
```

| Flag | Env | Purpose |
|------|-----|---------|
| `--server <url>` | `ZEUS_OS_SERVER` | Zeus web URL (a trailing `/` or `/api/v1` is tolerated) |
| `--token <token>` | `ZEUS_OS_TOKEN` | Bearer token |
| `--insecure` | `ZEUS_OS_INSECURE` | Skip TLS verification (self-signed lab clusters only; warns on use) |
| `--timeout <secs>` | | Per-request timeout, default 30 |

Routes used: `GET/POST /api/v1/velero/backups`, `GET/POST /api/v1/velero/restores`,
`GET /api/v1/vm-templates`, `GET /api/v1/networkpolicies`, `GET /api/v1/network-attachments`,
`GET /api/v1/tenancy/tenants`. `template get` filters the list client-side (the server has no
single-template route). `backup restore` checks the backup is visible before creating the restore.

### Tokens: use scoped `v9s_*` tokens

An API token with an **empty scope list is unrestricted**: it can do everything its role allows.
For automation create a `v9s_*` token with explicit scopes (for example `read` for the listing
commands) and, where possible, a tenant-limited role. The `create`/`restore` commands need a token
that permits writes.

### Errors

Errors are printed as `Error: ...` and exit 1. HTTP failures are mapped to actionable text:
401 (missing/invalid token), 403 (role/tenant/scope denies the operation), 404, 429, other 5xx,
plus connection, TLS and timeout failures naming the server URL.

## The `zeus-os-client` crate

`client/` is a small typed HTTP client (`ApiClient`, `ClientConfig`, `ClientError`) for
`/api/v1`, usable from other Rust tools. TLS verification is on unless `insecure` is set, the
token is never printed in `Debug` output, and path segments are validated before interpolation.
