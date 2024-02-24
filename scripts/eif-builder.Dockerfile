# amazonlinux:2023.3.20240131.0 linux/amd64
FROM amazonlinux@sha256:62ebd855c09b363009221442fcb1d09aca167d4ba58f2cfd14e00e59ca2f2d54

# Install nitro-cli
RUN dnf install aws-nitro-enclaves-cli aws-nitro-enclaves-cli-devel -y

RUN mkdir /output

# Command to build EIF
ENTRYPOINT ["/bin/bash", "-c", "nitro-cli build-enclave --docker-uri ${DOCKER_IMAGE_TAG}:latest --output-file /output/enclave.eif && nitro-cli describe-eif --eif-path /output/enclave.eif > /output/eif-info.txt"]
