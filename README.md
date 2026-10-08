# Nitro Enclaves EIF build action

Builds an AWS Nitro Enclaves EIF from a Dockerfile with a **custom kernel** and
outputs the EIF, its `describe-eif` JSON, PCR0-2 and the EIF sha256.

How it works:

1. The app image is built with BuildKit (`docker-container` driver) using
   `SOURCE_DATE_EPOCH=0` and `rewrite-timestamp=true`, so identical inputs give
   an identical image.
2. An Amazon Linux 2023 container with a pinned `nitro-cli` replaces
   `/usr/share/nitro_enclaves/blobs` with your kernel blobs and runs
   `nitro-cli build-enclave` + `describe-eif`.

No registry, no signing: the EIF is a plain file you upload or publish yourself.

## Usage

```yaml
steps:
  - uses: actions/checkout@v4

  - name: Build EIF
    id: eif
    uses: idos-network/nitro-enclaves-eif-build-action@v2
    with:
      context: enclave-service/
      dockerfile: Dockerfile
      kernel-blobs: aws-nitro-kernel/blobs/
      eif-name: idos-enclave.eif
      build-args: |
        S3_SECRETS_BUCKET=${{ secrets.STAGING_S3_BUCKET }}
        S3_SECRETS_REGION=${{ vars.STAGING_S3_REGION }}

  - uses: actions/upload-artifact@v4
    with:
      name: idos-enclave-eif-${{ github.sha }}
      path: |
        ${{ steps.eif.outputs.eif-path }}
        ${{ steps.eif.outputs.info-path }}

  - name: Summary
    run: |
      {
        echo "sha256: ${{ steps.eif.outputs.eif-sha256 }}"
        echo "PCR0: ${{ steps.eif.outputs.pcr0 }}"
        echo "PCR1: ${{ steps.eif.outputs.pcr1 }}"
        echo "PCR2: ${{ steps.eif.outputs.pcr2 }}"
      } >> "$GITHUB_STEP_SUMMARY"
```

## Inputs

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `context` | yes | | Docker build context, relative to the repo root |
| `dockerfile` | no | `Dockerfile` | Dockerfile path, relative to the context |
| `kernel-blobs` | yes | | Dir with `bzImage`, `cmdline`, `init`, `linuxkit`, `nsm.ko` |
| `build-args` | no | | `KEY=VALUE` per line, passed as `--build-arg` |
| `eif-name` | no | `enclave.eif` | Output file name |

## Outputs

`eif-path`, `info-path`, `eif-sha256`, `pcr0`, `pcr1`, `pcr2`.

## Verify on the host

```bash
nitro-cli describe-eif --eif-path idos-enclave.eif | jq .Measurements
```

The values must match the PCRs printed by the workflow.

## Reproducibility limits

Image timestamps are normalised, but anything the Dockerfile fetches
unpinned (e.g. `apt-get install` without versions) can still change between
builds. The guarantee this action gives is: the PCRs it prints belong to the
exact EIF file it produced.

## Requirements

Linux X64 runner with Docker (GitHub-hosted `ubuntu-latest` works).
