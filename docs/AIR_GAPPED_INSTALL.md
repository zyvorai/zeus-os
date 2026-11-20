# Air-gapped Zeus OS / v9s install

For environments without outbound internet from the cluster.

## Prerequisites

1. Build the container image on a connected bastion, save with `podman save` / `docker save`
2. Transfer image tarball + Helm chart + `ui/dist` bundle to the air-gap zone
3. Import image into cluster containerd (`ctr images import` on k3s)

## Configure engines offline

Set explicit URLs — auto-discovery will not reach node IPs outside the enclave:

```yaml
config:
  transivaUrl: "https://engines.internal:5080"
  hyper2kvmUrl: "https://engines.internal:5070"
  guestkitUrl: "https://engines.internal:5092"
  packetwolfHost: "packetwolf.internal"
  packetwolfTls: true
```

## Deploy

```bash
./scripts/deploy-remote.sh AIRGAP_HOST admin --k3s --skip-cluster-prereqs
```

Skip `--ui-pages-e2e` if Playwright cannot run from your workstation.

## Verification

```bash
kubectl get pods -n zeus-os
curl -k https://AIRGAP_HOST:30050/api/v1/health
python3 scripts/e2e-remediation-audit.py https://AIRGAP_HOST:30050
```

PacketWolf and migration engines are optional — v9s day-2 centers degrade gracefully when engines are unreachable.
