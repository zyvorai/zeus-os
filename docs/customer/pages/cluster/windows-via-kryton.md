# Windows via Kryton

Zeus OS can create Windows machines by calling **Kryton’s REST API** (no Kryton UI embed).
Day-2 (VNC, NodePort RDP, GuestKit) stays in Zeus.

## When to use it

- Prefer **Kryton catalog** in the Create VM wizard when Settings → Network shows Kryton **Connected**.
- Use **Build with Kryton** on Image Factory for golden-image builds Kryton owns (dockur install → Sysprep → CDI bootstrap).
- Keep Zeus Autounattend / ISO / Zeus Image Factory PVC paths when Kryton is not deployed.

## Catalog (12 dockur IDs)

Zeus built-in Windows templates match Kryton’s catalog (template id = Kryton `imageId`):

| Desktop | Server |
|---------|--------|
| `windows-11-enterprise`, `windows-11-pro`, `windows-11-ltsc` | `windows-server-2025`, `windows-server-2022` |
| `windows-10-enterprise`, `windows-10-pro`, `windows-10-ltsc` | `windows-server-2019`, `windows-server-2016` |
| `windows-tiny11`, `windows-tiny11-core` | |

Legacy Zeus-only IDs (`windows-11`, `windows-10`, `windows-server-2012-r2`, `windows-server-sql-2022`) are no longer primary marketplace templates.

## Operator wiring

| Helm / env | Purpose |
|------------|---------|
| `config.krytonUrl` / `ZEUS_OS_KRYTON_URL` | Kryton base URL (lab kubevirt API often `:9088`) |
| `config.krytonApiKey` or Secret / `ZEUS_OS_KRYTON_API_KEY` | API bearer token |
| `config.krytonApiKeySecretName` | Prefer Secret (`api-key` key) over plaintext |
| `config.krytonProject` / `ZEUS_OS_KRYTON_PROJECT` | Default project (`default`) |
| `config.krytonEnabled: false` / `ZEUS_OS_KRYTON=off` | Kill-switch |

The API key stays on the server. The browser only calls `/api/v1/kryton/*` on Zeus.
Do **not** drop the API key based on URL shape (in-cluster vs host IP).

### Lab harden (Kryton)

On the Kryton host, after deploy:

```bash
# Kryton repo
./scripts/deploy-remote.sh <host> <user> --quick --key
make harden-lab H=<host> U=<user>
# kubevirt API :9088, dockur lab :7088, token ~/.kryton/lab.token
```

Wire into Zeus (example):

```bash
TOKEN=$(ssh <user>@<host> 'cat ~/.kryton/lab.token')
kubectl -n zeus-os create secret generic zeus-os-kryton-apikey \
  --from-literal=api-key="$TOKEN" --dry-run=client -o yaml | kubectl apply -f -
helm upgrade zeus-os ./chart -n zeus-os --reuse-values \
  --set-string config.krytonUrl=http://<host>:9088 \
  --set-string config.krytonApiKeySecretName=zeus-os-kryton-apikey \
  --set-string config.krytonProject=default \
  --set config.krytonEnabled=true
```

Verify: Settings → Network → Kryton **Connected**, or
`GET /api/v1/kryton/status` → `configured: true`, `healthy: true`.

## Zeus API surface

| Route | Purpose |
|-------|---------|
| `GET /api/v1/kryton/status` | Configured / healthy / capabilities / doctor |
| `GET /api/v1/kryton/images` | Live catalog |
| `POST /api/v1/kryton/machines` | Create Windows machine |
| `GET/DELETE …/kryton/machines/{id}` | List / delete |
| `POST …/kryton/machines/{id}/{start\|stop\|reboot}` | Lifecycle |
| `GET/POST /api/v1/kryton/golden` | List / start golden |
| `GET /api/v1/kryton/golden/{id}` | Poll build |
| `POST /api/v1/kryton/golden/{id}/bootstrap` | Bootstrap DataSource into cluster |

## Create body (kubevirt provider)

`POST /kryton/machines` (Zeus or Kryton) requires a disk size. Omitting it returns
`disk.sizeGiB must be between 16 and 65536`. The Create VM wizard sends
`disk.sizeGiB` from the catalog `defaultDiskGiB` (see `useCreateVmSubmit`).

```json
{
  "name": "win-lab-01",
  "image": "windows-tiny11-core",
  "project": "default",
  "compute": { "cpu": 2, "memoryMiB": 4096 },
  "disk": { "sizeGiB": 64 }
}
```

When Kryton’s provider is **kubevirt**, only images with a CDI `DataSource` in
`kryton-images` create successfully (`GET /kryton/status` → doctor
`kubevirt-images`).

## Golden images — do not trust a one-minute “ready”

A real dockur install + Sysprep takes **well over an hour**. If `GET /kryton/golden/{id}`
flips to `ready` in ~1 minute, treat the qcow2 as **suspect**: VNC of a clone often shows
Windows Setup (“restarted unexpectedly”) instead of a desktop, and RDP never comes up.

Before bootstrap / create:

1. Confirm the dockur console finished install + Sysprep (not stuck at “58% windows_setup”).
2. Confirm `outputPath` qcow2 is from a **FINALIZE=1** capture (Kryton
   `build-golden-image.sh` must preserve parent `FINALIZE` / `IMAGE_ID` — see Kryton
   `docs/GOLDEN-IMAGES.md`).
3. Prefer `availability: stored` + a fresh sha after a long build over catalog aliases that
   share one path (lab saw `windows-11-pro` and `windows-tiny11-core` pointing at the same
   core11 qcow2).

### CDI bootstrap gotchas

| Symptom | Cause / fix |
|---------|-------------|
| Bootstrap / `virtctl image-upload` can’t reach uploadproxy | Service is ClusterIP-only — port-forward or set an external uploadproxy URL |
| Import fails on small PVC | Virtual disk can be ~80 Gi — use a **≥96 Gi** PVC |
| `IncompatibleVolumeModes` on clone | Golden DV was **Filesystem**; target expected **Block** (or reverse). Match volume modes on clone, or rebuild golden as Block |
| Doctor lists missing DataSources | Run `POST /kryton/golden/{id}/bootstrap` or Kryton `bootstrap-kubevirt-images.sh` after a real golden |

## Day-2 (VNC + native RDP)

After create, open the VM in Zeus (VNC, native RDP NodePort, GuestKit) using Kryton’s
`providerRef` namespace/name (`zeusVm` deep-link). Guest agent tooling remains GuestKit /
QEMU-GA — not Kryton.

Native RDP (`POST /api/v1/vms/{ns}/{name}/rdp-access/expose`) needs all of:

1. **Guest listening on 3389** (finalized golden / RDP enabled — not mid-Setup).
2. **Masquerade port 3389** on the VM interface (`vm_spec_has_rdp_port`; Zeus Windows
   create merges this automatically — hand-rolled VMs must add it and restart).
3. **Service selector** `vm.kubevirt.io/name=<vm>` (KubeVirt always labels virt-launcher
   pods this way). Empty endpoints + `No route to host` on the NodePort usually means a
   stale `kubevirt.io/vm=` selector.

Probe from the host: Service endpoints → pod IP:3389 (masquerade DNAT to `10.0.2.2`) →
NodePort. Guest-agent absence is common on Tiny11; use VNC to confirm desktop vs Setup.

## E2E catalog script

```bash
ZEUS_OS_E2E_INSECURE=1 ./scripts/e2e-kryton-catalog.sh https://<host>:30050
# Writes docs/kryton-e2e-ledger-<timestamp>.md (or LEDGER=…)
```

Sequential golden → bootstrap → create → delete for every catalog image. Wall time is long
(hours); Microsoft media/licensing remains operator responsibility.

## Related

- [WINDOWS_ENTERPRISE.md](../../../features/WINDOWS_ENTERPRISE.md)
- [Image Factory](./image-factory.md)
- [Windows Licensing](../run/windows-licensing.md)
