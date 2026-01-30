# NVIDIA Container Toolkit Playbook

Enables GPU access for Docker containers.

## What It Does

1. Adds NVIDIA container toolkit repository
2. Installs `nvidia-container-toolkit`
3. Configures Docker runtime to use NVIDIA GPU
4. Restarts Docker (only if config changed)

## Usage

```bash
make nvidia-container
```

## Verification

```bash
ssh lab-owner@shadowlands
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
```

Should show the GPU from inside the container.

## Prerequisites

- NVIDIA drivers installed (`make nvidia`)
- Docker installed (`make bootstrap`)
