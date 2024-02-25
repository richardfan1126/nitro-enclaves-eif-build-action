#!/bin/bash

set -e

cd ${GITHUB_WORKSPACE}/"${DOCKER_CONTEXT_DIR}"

# Generate a random tag name for the app image
DOCKER_IMAGE_TAG=$(tr -dc a-z0-9 < /dev/random | head -c 13; echo)

##########################
# Build app docker image #
##########################
KANIKO_EXECUTOR_IMAGE=gcr.io/kaniko-project/executor@sha256:e935bfe222bc3ba84797e90a95fcfb1a63e61bcf81275c2cac5edfb0343b2e85 # kaniko/executor:v1.18.0

docker run \
    -v `pwd`:/workspace \
    ${KANIKO_EXECUTOR_IMAGE} \
    --dockerfile "${DOCKERFILE_PATH}" \
    --context dir:///workspace/ \
    --cache=false \
    --reproducible \
    --no-push \
    --destination ${DOCKER_IMAGE_TAG}:latest \
    --tar-path /workspace/docker.tar

# Load image into Docker daemon
docker load < docker.tar
rm -f docker.tar

#############
# Build EIF #
#############
cd ${GITHUB_ACTION_PATH}/scripts

# Create directory for EIF output
if [[ ! -d ${EIF_OUTPUT_PATH} ]]; then
    mkdir ${EIF_OUTPUT_PATH}
fi

# Build EIF builder image
docker build -t eif-builder -f eif-builder.Dockerfile .

# Get local docker socket path
DOCKER_SOCK_PATH=$(docker context inspect | jq -r '.[0].Endpoints.docker.Host' | sed "s^unix://^^")

# Run EIF builder with Docker-in-Docker
docker run -v ${DOCKER_SOCK_PATH}:/var/run/docker.sock -v ${EIF_OUTPUT_PATH}:/output -e DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG} eif-builder

# Output
echo "eif-file-path=${EIF_OUTPUT_PATH}/enclave.eif" >> ${GITHUB_OUTPUT}
echo "eif-info-path=${EIF_OUTPUT_PATH}/eif-info.txt" >> ${GITHUB_OUTPUT}
