# SearchSploit Container

Containerized [SearchSploit / Exploit-DB](https://www.exploit-db.com/searchsploit) image intended for use with Docker-compatible runtimes, SingularityCE, and Apptainer.

The container is automatically built with GitHub Actions and published to GitHub Container Registry (GHCR).

The main use case is to run SearchSploit on Linux workstations or HPC environments without installing Exploit-DB or its dependencies directly on the host system.

## Features

* Based on `debian:bookworm-slim`
* Includes the official Exploit-DB repository
* Includes SearchSploit and its local exploit database
* Supports standard SearchSploit queries
* Supports CVE searches
* Supports `searchsploit -m` for copying exploit files to the host working directory
* Supports Nmap XML input with `searchsploit --nmap`
* Designed for conversion from OCI/Docker images to Singularity SIF
* Automatically rebuilt monthly to refresh the Exploit-DB database
* Also rebuilt when the Dockerfile or GitHub Actions workflow is updated

## Container Registry

The latest image is available from GHCR:
please visit the `package` page.

```text
ghcr.io/tomoki-ueda-cybersec/my-searchsploit-container:<version>
```

## SingularityCE

### Pull the image

SingularityCE can directly pull the OCI image from GHCR and convert it into a SIF image:

```bash
mkdir -p ~/containers

singularity pull \
    ~/containers/searchsploit.sif \
    docker://ghcr.io/tomoki-ueda-cybersec/my-searchsploit-container:<version>
```

This creates:

```text
~/containers/searchsploit.sif
```

### Basic usage

```bash
singularity exec \
    ~/containers/searchsploit.sif \
    searchsploit openssh
```

Example:

```bash
singularity exec \
    ~/containers/searchsploit.sif \
    searchsploit "Apache 2.4"
```

### Search by CVE

```bash
singularity exec \
    ~/containers/searchsploit.sif \
    searchsploit --cve 2021-44228
```

### Show exploit path

```bash
singularity exec \
    ~/containers/searchsploit.sif \
    searchsploit -p <EDB-ID>
```

For example:

```bash
singularity exec \
    ~/containers/searchsploit.sif \
    searchsploit -p 39446
```

### Copy an exploit to the host

SearchSploit's `-m` option copies the selected exploit into the current working directory.

```bash
mkdir -p ~/searchsploit-test
cd ~/searchsploit-test

singularity exec \
    ~/containers/searchsploit.sif \
    searchsploit -m <EDB-ID>
```

Because Singularity normally bind-mounts the current working directory, the copied exploit will appear directly on the host filesystem.

For example:

```bash
searchsploit -m 39446
```

may create a file such as:

```text
39446.py
```

in the current directory.

## Nmap XML Integration

The image includes `xmllint` via `libxml2-utils`, allowing SearchSploit to process Nmap XML output.

Generate XML output with Nmap:

```bash
nmap -sV <TARGET_IP> -oX scan.xml
```

Then pass it to SearchSploit:

```bash
singularity exec \
    ~/containers/searchsploit.sif \
    searchsploit --nmap scan.xml
```

## Recommended Alias

To use the containerized SearchSploit almost like a native installation, add the following alias to `~/.bashrc`:

```bash
alias searchsploit='singularity exec ~/containers/searchsploit.sif searchsploit'
```

Reload the shell configuration:

```bash
source ~/.bashrc
```

SearchSploit can then be used normally:

```bash
searchsploit openssh 9.6
searchsploit "Apache 2.4"
searchsploit --cve 2021-44228
searchsploit -p 39446
searchsploit -m 39446
searchsploit --nmap scan.xml
```

## Updating the SIF Image

The GHCR image is periodically rebuilt with a fresh copy of the Exploit-DB repository.

To update the local SIF image:

```bash
singularity pull --force \
    ~/containers/searchsploit.sif \
    docker://ghcr.io/tomoki-ueda-cybersec/my-searchsploit-container:<version>
```

The intended update model is:

```text
Exploit-DB
    ↓
GitHub Actions
    ↓
Updated OCI image on GHCR
    ↓
singularity pull --force
    ↓
Updated SIF
```

Updating Exploit-DB from inside the SIF with:

```bash
searchsploit -u
```

is not recommended because SIF images are designed to be immutable.

## Apptainer

The same image can also be used with Apptainer.

Pull:

```bash
apptainer pull \
    ~/containers/searchsploit.sif \
    docker://ghcr.io/tomoki-ueda-cybersec/my-searchsploit-container:<version>
```

Run:

```bash
apptainer exec \
    ~/containers/searchsploit.sif \
    searchsploit openssh
```

A corresponding alias can be used:

```bash
alias searchsploit='apptainer exec ~/containers/searchsploit.sif searchsploit'
```

## Docker

The OCI image can also be run directly with Docker:

```bash
docker pull ghcr.io/tomoki-ueda-cybersec/my-searchsploit-container:<version>
```

Because `searchsploit` is configured as the container entrypoint:

```bash
docker run --rm \
    ghcr.io/tomoki-ueda-cybersec/my-searchsploit-container:<version> \
    openssh
```

For operations that write files to the current directory, mount a host directory:

```bash
docker run --rm \
    -v "$PWD:/work" \
    -w /work \
    ghcr.io/tomoki-ueda/searchsploit-container:<version> \
    -m <EDB-ID>
```

## Build

The repository contains:

```text
.
├── Dockerfile
└── .github/
    └── workflows/
        └── build.yml
```

GitHub Actions builds the image for:

```text
linux/amd64
```

and publishes it to:

```text
ghcr.io/tomoki-ueda-cybersec/my-searchsploit-container
```

Two tags are generated:

```text
latest
<Git commit SHA>
```

The commit SHA tag can be used when a reproducible, fixed version of the Exploit-DB database is preferred.

Example:

```bash
singularity pull \
    searchsploit-frozen.sif \
    docker://ghcr.io/tomoki-ueda-cybersec/my-searchsploit-container:<COMMIT_SHA>
```

## Automated Rebuilds

The GitHub Actions workflow is triggered by:

* changes to `Dockerfile`
* changes to `.github/workflows/build.yml`
* manual execution with `workflow_dispatch`
* a scheduled monthly rebuild

The monthly rebuild retrieves a fresh copy of the upstream Exploit-DB repository during the Docker build.

## Upstream Project

SearchSploit and the Exploit-DB database are maintained by Offensive Security:

* Exploit-DB: https://www.exploit-db.com/
* SearchSploit: https://www.exploit-db.com/searchsploit
* Exploit-DB GitLab repository: https://gitlab.com/exploit-database/exploitdb

This repository only provides a containerized environment for the upstream project.

## Disclaimer

This container is intended for legitimate security research, penetration testing, CTFs, laboratory environments, and systems for which you have explicit authorization to test.

Use of the included exploit code is the responsibility of the user.
