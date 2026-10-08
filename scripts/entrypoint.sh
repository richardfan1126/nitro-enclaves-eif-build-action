#!/bin/bash
set -euo pipefail

for f in bzImage cmdline init linuxkit nsm.ko; do
  [[ -f "/blobs/$f" ]] || { echo "Missing kernel blob: /blobs/$f" >&2; exit 1; }
done

# nitro-cli has no flag for the blobs dir; replace the stock ones.
rm -rf /usr/share/nitro_enclaves/blobs
cp -a /blobs /usr/share/nitro_enclaves/blobs

nitro-cli build-enclave --docker-uri "$APP_IMAGE" --output-file "/output/$EIF_NAME"
nitro-cli describe-eif --eif-path "/output/$EIF_NAME" > "/output/${EIF_NAME%.eif}-info.json"
