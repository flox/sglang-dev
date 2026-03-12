# SGLang Runtime Environment — All GPUs (SM75–SM120), AVX2

Flox runtime environment wrapping a pre-built SGLang Nix store path. Supports all NVIDIA GPUs from T4 through RTX 5090 (SM75–SM120), compiled with AVX2 CPU instructions and CUDA 12.8.

## Prerequisites

- **NVIDIA driver 550+** (run `nvidia-smi` — "CUDA Version" must show 12.8 or higher)
- **Nix store** — the SGLang build output must exist at its `/nix/store/` path
- **Flox** — [flox.dev](https://flox.dev)

## Quick Start

```bash
cd runtime-all-avx2
flox activate

# Python with full SGLang stack
python3.12 -c "import sglang; print(sglang.__version__)"

# Or use the sglang CLI wrapper directly
sglang --help
```

## Usage Examples

### Check CUDA availability

```python
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU: {torch.cuda.get_device_name(0)}")
print(f"CUDA version: {torch.version.cuda}")
```

### Launch an SGLang server

```bash
python3.12 -m sglang.launch_server \
  --model-path meta-llama/Llama-3.1-8B-Instruct \
  --port 30000
```

### Import SGLang in Python

```python
import sglang as sgl
from sglang import function, gen, set_default_backend, RuntimeEndpoint
```

## How It Works

The manifest at `.flox/env/manifest.toml` does three things:

1. **Sets store paths** — `SGLANG_STORE_PATH` and `SGLANG_PYTHON` point at the pre-built Nix derivations
2. **Builds PYTHONPATH from the full closure** — the `on-activate` hook runs `nix-store -qR` on the SGLang store path to discover all transitive dependencies, then filters for `lib/python3.12/site-packages` directories to construct `PYTHONPATH`
3. **Isolates the environment** — unsets any outer `PYTHONPATH`/`PYTHONHOME` so system Python packages cannot interfere, and sets `FLASHINFER_JIT_DIR` to a writable cache directory (the Nix store is read-only)

## After Rebuilds

When you rebuild the SGLang package (e.g. after updating a version), the store path changes. Update the manifest:

```bash
# Find the new store path
readlink result-sglang-python312-cuda12_8-all-avx2

# Edit runtime-all-avx2/.flox/env/manifest.toml
# Update SGLANG_STORE_PATH to the new path
# Update SGLANG_PYTHON if the Python version changed
```

## Known Limitations

- **FlashInfer JIT (`tvm_ffi`)**: Not available — the `apache-tvm-ffi` dependency is stripped. Pre-compiled cubins (9262 files) cover standard models and attention patterns
- **Store path hardcoded**: The Nix store path is hardcoded in `manifest.toml` and must be updated after each rebuild
- **x86_64-linux only**: This environment targets `x86_64-linux` with AVX2 CPU instructions
