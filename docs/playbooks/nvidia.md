# NVIDIA Playbook

Installs NVIDIA proprietary drivers and CUDA support via RPM Fusion.

## What It Does

1. Adds RPM Fusion free and nonfree repositories
2. Installs `akmod-nvidia` (auto-rebuilds kernel module on updates)
3. Installs `xorg-x11-drv-nvidia-cuda` for CUDA support
4. Builds and loads the NVIDIA kernel module

## Usage

```bash
make nvidia
```

## Verification

After running, verify the driver is loaded:

```bash
ssh lab-owner@shadowlands
nvidia-smi
```

Should show your GPU (RTX 3090) and driver version.

## Notes

- No reboot required - the playbook builds and loads the module directly
- Kernel module will auto-rebuild on kernel updates via akmods
- Required before running the Ollama playbook
