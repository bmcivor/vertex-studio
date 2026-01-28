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

## Secure Boot

**Secure Boot must be disabled** for RPM Fusion's `akmod-nvidia` to load.

As of 30 Jan 2026, NVIDIA's official repository doesn't have Fedora 43 packages yet - when they do, those drivers will be signed with NVIDIA's key (trusted by Secure Boot) and this won't be necessary. Until then, RPM Fusion's `akmod-nvidia` signs modules with a locally-generated key, which requires MOK enrollment. MOK enrollment is unreliable on some motherboards (notably ASUS X99 boards have a firmware bug preventing MOK variable writes).

If you see `Key was rejected by service` when loading the nvidia module:

1. Reboot into BIOS/UEFI
2. Disable Secure Boot
3. Reboot and run `make nvidia` again

## Notes

- No reboot required once Secure Boot is disabled - the playbook builds and loads the module directly
- Kernel module will auto-rebuild on kernel updates via akmods
- Required before running the Ollama playbook
