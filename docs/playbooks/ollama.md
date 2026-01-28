# Ollama Playbook

Installs [Ollama](https://ollama.com/) for running local LLMs with GPU acceleration.

## What It Does

1. Downloads and installs Ollama
2. Enables and starts the Ollama service
3. Pulls the LLaVA model (vision + language)

## Prerequisites

Run the NVIDIA playbook first:

```bash
make nvidia
```

## Usage

```bash
make ollama
```

## Interacting with Ollama

SSH into the lab machine:

```bash
ssh lab-owner@shadowlands
```

### Interactive Chat (CLI)

Start a chat session:

```bash
ollama run llava
```

Type your message and press Enter. Use `/bye` to exit.

### Vision/Image Analysis

LLaVA can analyze images. Pass an image path:

```bash
ollama run llava "Describe this image in detail" /path/to/image.jpg
```

Or from a URL (download first):

```bash
curl -o /tmp/image.jpg https://example.com/image.jpg
ollama run llava "What's happening in this image?" /tmp/image.jpg
```

### One-off Prompts

For scripting or quick queries without interactive mode:

```bash
echo "Explain quantum computing in simple terms" | ollama run llava
```

### API Usage

Ollama exposes an API on port 11434.

**Generate (non-streaming):**

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llava",
  "prompt": "Write a haiku about coding",
  "stream": false
}'
```

**Chat format (conversation history):**

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llava",
  "messages": [
    {"role": "user", "content": "What is Rust?"},
    {"role": "assistant", "content": "Rust is a systems programming language..."},
    {"role": "user", "content": "How does it handle memory?"}
  ],
  "stream": false
}'
```

**Vision via API (base64 image):**

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llava",
  "prompt": "What do you see?",
  "images": ["'$(base64 -w0 /path/to/image.jpg)'"]
}'
```

### Python Usage

```python
import requests

response = requests.post('http://localhost:11434/api/generate', json={
    'model': 'llava',
    'prompt': 'Explain this code:\n\ndef fib(n): return n if n < 2 else fib(n-1) + fib(n-2)',
    'stream': False
})
print(response.json()['response'])
```

With the official library:

```bash
pip install ollama
```

```python
import ollama

response = ollama.chat(model='llava', messages=[
    {'role': 'user', 'content': 'Why is the sky blue?'}
])
print(response['message']['content'])
```

## Model Management

### List Models

```bash
ollama list
```

### Pull New Models

```bash
ollama pull dolphin-mistral   # Uncensored text model
ollama pull llama3            # Meta's Llama 3
ollama pull mistral           # Mistral 7B
ollama pull codellama         # Code-focused model
```

### Remove Models

```bash
ollama rm llava
```

### Model Info

```bash
ollama show llava
```

## GPU Monitoring

Check GPU usage while running:

```bash
nvidia-smi
```

Or watch continuously:

```bash
watch -n 1 nvidia-smi
```

## Exposing Remotely

By default Ollama only listens on localhost. To access via Tailscale:

```bash
sudo systemctl edit ollama
```

Add:

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
```

Restart:

```bash
sudo systemctl restart ollama
```

Access from any Tailscale device:

- API: `http://100.126.155.102:11434`
- Example: `curl http://100.126.155.102:11434/api/generate -d '{"model":"llava","prompt":"Hello"}'`

## Troubleshooting

**Model not loading:**

```bash
# Check service status
sudo systemctl status ollama

# View logs
journalctl -u ollama -f
```

**Out of GPU memory:**

Try a smaller model or quantized version:

```bash
ollama pull llava:7b-q4_0  # 4-bit quantized, uses less VRAM
```

**Service not starting:**

```bash
# Check NVIDIA driver
nvidia-smi

# Restart service
sudo systemctl restart ollama
```
