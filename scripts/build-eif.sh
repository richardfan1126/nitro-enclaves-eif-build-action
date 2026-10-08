#!/bin/bash
# Builds the app image reproducibly, then turns it into an EIF inside an
# Amazon Linux container running nitro-cli with the custom kernel blobs.
set -euo pipefail

: "${CONTEXT:?}" "${DOCKERFILE:?}" "${KERNEL_BLOBS:?}" "${EIF_NAME:?}" "${OUTPUT_DIR:?}"
BUILD_ARGS="${BUILD_ARGS:-}"
APP_IMAGE=enclave-app:latest
BUILDER=eif-builder
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

##########################################
# App image, reproducible                #
##########################################
# docker-container driver is required: the default docker driver sets the image
# "created" time but silently ignores rewrite-timestamp for file mtimes.
docker buildx inspect "$BUILDER" >/dev/null 2>&1 \
  || docker buildx create --name "$BUILDER" --driver docker-container >/dev/null

build_args=()
while IFS= read -r line; do
  [[ -n "$line" ]] && build_args+=(--build-arg "$line")
done <<< "$BUILD_ARGS"

docker buildx --builder "$BUILDER" build \
  --platform linux/amd64 \
  --build-arg SOURCE_DATE_EPOCH=0 \
  --provenance=false --sbom=false \
  --output type=docker,rewrite-timestamp=true \
  ${build_args[@]+"${build_args[@]}"} \
  -f "$CONTEXT/$DOCKERFILE" -t "$APP_IMAGE" "$CONTEXT"

##########################################
# EIF                                    #
##########################################
mkdir -p "$OUTPUT_DIR"
docker build --platform linux/amd64 -t eif-builder-image -f "$SCRIPTS_DIR/eif-builder.Dockerfile" "$SCRIPTS_DIR"

DOCKER_SOCK=$(docker context inspect --format '{{.Endpoints.docker.Host}}' | sed 's#^unix://##')

docker run --rm --platform linux/amd64 \
  -v "$DOCKER_SOCK":/var/run/docker.sock \
  -v "$(realpath "$KERNEL_BLOBS")":/blobs:ro \
  -v "$(realpath "$OUTPUT_DIR")":/output \
  -e APP_IMAGE="$APP_IMAGE" -e EIF_NAME="$EIF_NAME" \
  eif-builder-image
