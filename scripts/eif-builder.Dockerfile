# amazonlinux:2023 linux/amd64
FROM amazonlinux@sha256:500790b3c980438d9d6cde6c149e59dda1992660941a814198b95ed56574fb96

# Pinned: a nitro-cli upgrade changes the EIF layout and therefore the PCRs.
ARG NITRO_CLI_VERSION=1.5.0
RUN dnf install -y \
      "aws-nitro-enclaves-cli-${NITRO_CLI_VERSION}" \
      "aws-nitro-enclaves-cli-devel-${NITRO_CLI_VERSION}" \
    && dnf clean all

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
