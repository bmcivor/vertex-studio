# Stable Diffusion Playbook

Deploys AUTOMATIC1111 Stable Diffusion WebUI using [simonmcnair/stable-diffusion-webui-docker](https://github.com/simonmcnair/stable-diffusion-webui-docker).

## What It Does

1. Clones the stable-diffusion-webui-docker repository to `/opt/stable-diffusion/`
2. Builds and starts the AUTOMATIC1111 WebUI container with GPU support
3. Exposes web interface on port 7860

## Usage

```bash
make stable-diffusion
```

Note: First run builds the container and downloads models. This takes a while.

## Accessing the WebUI

After deployment, access via:

- Local network: `http://shadowlands:7860`
- Tailscale: `http://<tailscale-ip>:7860`

## API Usage

The WebUI exposes an API at the same port:

```bash
# txt2img example
curl -X POST http://shadowlands:7860/sdapi/v1/txt2img \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "a photo of an astronaut riding a horse on mars",
    "steps": 20,
    "width": 1024,
    "height": 1024
  }'
```

Response includes base64-encoded image in `images` array.

## Adding Models

Place additional models in `/opt/stable-diffusion/data/StableDiffusion/` on the lab machine:

```bash
# Example: download SDXL from HuggingFace
wget -O /opt/stable-diffusion/data/StableDiffusion/sd_xl_base_1.0.safetensors \
  https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
```

Restart the container to pick up new models:

```bash
cd /opt/stable-diffusion && docker compose --profile auto restart
```

## Output Directory

Generated images are saved to `/opt/stable-diffusion/output/`.

## Prerequisites

- NVIDIA drivers (`make nvidia`)
- NVIDIA container toolkit (`make nvidia-container`)
