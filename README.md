# AWS Nitro Enclaves EIF Build GitHub Action

This GitHub Action use [kaniko](https://github.com/GoogleContainerTools/kaniko) and Amazon Linux container with [nitro-cli](https://docs.aws.amazon.com/enclaves/latest/user/nitro-enclave-cli.html) to build a reproducible AWS Nitro Enclaves EIF file and its information.

## Artifact upload and signing

This actions has an optional feature to upload the EIF file and its info the [ghcr registry](https://docs.github.com/en/packages/quickstart).

There is another optional feature to use [SigStore](https://www.sigstore.dev/) and the Github actions token to sign the upload artifact.

To enable these feature, set the input `enable-ghcr-push` _(For artifact upload)_ and `enable-artifact-sign` _(For artifact signing)_ to `true`

## Usage

Example

```yaml
# The following permissions are required when "enable-ghcr-push" is true
permissions:
  packages: write
  id-token: write

steps:
  - name: Build EIF
    id: build-eif
    uses: richardfan1126/nitro-enclaves-eif-build-action@v1
    with:
      docker-build-context-path: app/
      dockerfile-path: Dockerfile
      enable-ghcr-push: true
      enable-artifact-sign: true
      eif-file-name: enclave.eif
      eif-info-file-name: enclave-info.json
      artifact-tag: latest
      github-token: ${{ secrets.GITHUB_TOKEN }}
```

See [richardfan1126/nitro-enclaves-cosign-sandbox](https://github.com/richardfan1126/nitro-enclaves-cosign-sandbox) for sample use case.

### Pre-requisites

This action only runs on **x64 Linux** runner.

If `enable-ghcr-push` is `true`, the following permission is required for the workflow:

* `packages: write`

* `id-token: write`

### Inputs

* `docker-build-context-path`

    The path of the Docker build context. Usually, it is the directory containing your `Dockerfile`.

    This path is relative to your GitHub project root directory.

* `dockerfile-path`

    (Default: `Dockerfile`)

    The path of the Dockerfile used to build the EIF file.

    This path is relative to `docker-build-context-path`

* `enable-ghcr-push`

    (Default: `false`)

    Set to `true` to upload artifacts into ghcr.

* `enable-artifact-sign`

    (Default: `false`)

    Set to `true` to use SigStore to sign the uploaded artifact on ghcr.

    If this input is `true`, `enable-ghcr-push` must also set to `true`.

* `eif-file-name`

    The filename of the EIF file uploaded to ghcr

    This must be set if `enable-ghcr-push` is `true`.

* `eif-info-file-name`

    The filename of the EIF info text file uploaded to ghcr

    This must be set if `enable-ghcr-push` is `true`.

* `artifact-tag`

    The tag of the artifact uploaded to ghcr

    This must be set if `enable-ghcr-push` is `true`.

* `github-token`

    The token used to sign in to ghcr

    This must be set if `enable-ghcr-push` is `true`.
    
    Suggest to use `${{ secrets.GITHUB_TOKEN }}`

### Outputs

* `eif-file-path`

    The path of the built EIF file

* `eif-info-path`

    The path of the text file containing the EIF information

    Example of the file content:

    ```json
    {
      "EifVersion": 4,
      "Measurements": {
        "HashAlgorithm": "Sha384 { ... }",
        "PCR0": "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        "PCR1": "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        "PCR2": "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
      },
      "IsSigned": false,
      "CheckCRC": true,
      "ImageName": "1111111111111",
      "ImageVersion": "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
      "Metadata": {
        "BuildTime": "2020-01-01T00:00:00.000000000+00:00",
        "BuildTool": "nitro-cli",
        "BuildToolVersion": "1.0.0",
        "OperatingSystem": "Linux",
        "KernelVersion": "4.0.0",
        "DockerInfo": {
          "Architecture": "amd64",
          "Author": "",
          "Comment": "",
          "Config": {
            "AttachStderr": false,
            "AttachStdin": false,
            "AttachStdout": false,
            "Cmd": [
              "/bin/sh",
              "-c",
              "/app"
            ],
            "Domainname": "",
            "Entrypoint": null,
            "Env": [
              "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
              "ARCH=x86_64"
            ],
            "ExposedPorts": null,
            "Hostname": "",
            "Image": "sha256:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
            "Labels": null,
            "OnBuild": null,
            "OpenStdin": false,
            "StdinOnce": false,
            "Tty": false,
            "User": "",
            "WorkingDir": "/app"
          },
          "Created": "0001-01-01T00:00:00Z",
          "DockerVersion": "",
          "Id": "sha256:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
          "Os": "linux",
          "Parent": "",
          "RepoDigests": [],
          "RepoTags": [
            "1111111111111:latest"
          ],
          "Size": 9999999,
          "VirtualSize": 9999999
        }
      }
    }
    ```

* `ghcr-artifact-digest`

    The digest of the pushed ghcr artifact.

    Only applicable when `enable-ghcr-push` is `true`.

* `ghcr-artifact-path`
    
    The full path of the pushed ghcr artifact.

    Only applicable when `enable-ghcr-push` is `true`.

* `rekor-log-index`

    The Rekor transparency log index of the signing.

    It can be used to find the signing log on [Rekor Search](https://search.sigstore.dev/)

    Only applicable when `enable-ghcr-push` is `true`.
