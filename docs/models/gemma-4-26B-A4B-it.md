# gemma-4-26B-A4B-it — Model Card

## Identity

| Field        | Value                                     |
| ------------ | ----------------------------------------- |
| Model        | Gemma 4 26B Instruct (MoE)                |
| Variant      | `unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q6_K` |
| Source       | `hf.co/unsloth/gemma-4-26B-A4B-it-GGUF`   |
| Parameters   | 25.2B (+ 572M CLIP vision projector)      |
| Architecture | gemma4 (MoE), ~4B active params per token |
| Context      | 262,144 tokens                            |
| Embedding    | 2816                                      |
| Quantization | UD-Q6_K (Unsloth dynamic 6-bit k-quant)   |
| Capabilities | completion, vision (CLIP)                 |
| License      | Gemma Terms of Use (Google)               |

## Local Install

```
ollama pull hf.co/unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q6_K
ollama run  hf.co/unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q6_K
```

## Resource Requirements

| Resource    | Estimate                                     |
| ----------- | -------------------------------------------- |
| Disk        | ~22 GB                                       |
| RAM/VRAM    | ~22 GB unified memory (M-series) or VRAM     |
| Recommended | Apple M2 Max / M3 Pro or better (36 GB+ RAM) |

## Capabilities

- Instruction-tuned for chat, coding, reasoning, and summarization
- MoE architecture: low active-parameter cost per token (~4B) despite 26B total weights
- Strong multilingual support (Gemma 4 family)
- Q6_K quantization preserves most of the fp16 quality floor

## Notes

- `A4B` denotes ~4B active parameters (MoE routing)
- `UD-Q6_K` is an Unsloth-optimized dynamic quantization at 6-bit k-quant precision
- Prefer this over Q4 variants when RAM allows — quality difference is noticeable on
  reasoning tasks
- API endpoint via Ollama: `http://localhost:11434` (OpenAI-compatible)

## Usage in nu_libs / lib/ai

```nu
# Point lib/ai at local ollama endpoint
$env.AI_CONFIG.provider = "openai"
$env.AI_CONFIG.base_url = "http://localhost:11434/v1"
$env.AI_CONFIG.model    = "hf.co/unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q6_K"
$env.AI_CONFIG.api_key  = "ollama"   # any non-empty string
```
