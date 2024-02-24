# AWS Nitro Enclaves EIF Build GitHub Action

This GitHub Action use [kaniko](https://github.com/GoogleContainerTools/kaniko) and Amazon Linux container with [nitro-cli](https://docs.aws.amazon.com/enclaves/latest/user/nitro-enclave-cli.html) to build a reproducible AWS Nitro Enclaves EIF file and its information.

## Usage

```yaml
  - name: Build EIF
    id: build-eif
    uses: richardfan1126/nitro-enclaves-eif-build-action@v1
    with:
      docker-build-context-path: app/
      dockerfile-path: Dockerfile
```

See [richardfan1126/nitro-enclaves-rust-demo](https://github.com/richardfan1126/nitro-enclaves-rust-demo) for sample use case.

### Pre-requisites

This action only runs on **x86 Linux** runner.

### Inputs

* `docker-build-context-path`

    The path of the Docker build context. Usually, it is the directory containing your `Dockerfile`.

    This path is relative to your GitHub project root directory.

* `dockerfile-path`

    The name of the Dockerfile used to build the EIF file.

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
