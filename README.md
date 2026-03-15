# enhanced-oss-cad

Prototype work for extending the OSS CAD formal flow with better SystemVerilog
Assertion handling.

## Overview

This repo contains a local SVA frontend and standalone wrapper around `sby`:

- `tools/sva_lower.py`: lowers a supported SVA subset into Yosys-compatible
  formal RTL under `` `ifdef FORMAL ``
- `tools/sva_sby.py`: stages `.sv` or `.sby` inputs and runs the formal flow
- `formal`: the primary user-facing CLI
- `examples/sva/`: runnable assertion examples and `.sby` configs

The current lowering path supports a bounded subset including:

- named `sequence` / `property`
- `|->` and `|=>`
- fixed delay `##N`
- simple ranged delay `##[M:N]`
- bounded consecutive repetition `[*M:N]`
- simple chained bounded repetition such as `A[*M:N] ##K B`
- `assert property`, `assume property`, and `cover property`
- `disable iff`

For some operators outside that subset, the wrapper currently has an optional
EBMC fallback path.

## Quick Start

Make sure `sby` is on `PATH`. If you want the optional full-SVA fallback path,
also make sure `ebmc` is on `PATH`.

Run the local tests:

```bash
python3 tools/test_sva_lower.py
python3 tools/test_sva_sby.py
python3 tools/test_formal.py
```

Run the shared smoke test:

```bash
bash tools/smoke_test.sh
```

Run the standalone wrapper:

```bash
./formal examples/sva/assert_raw_delay_pass.sby
./formal examples/sva/assert_raw_delay_pass.sv
```

## CI And Push Gating

The repo now includes:

- `.github/workflows/smoke.yml`: runs the smoke test on every push and pull request
- `.githooks/pre-push`: blocks local pushes when the smoke test fails

Enable the repo-local `pre-push` hook in this clone with:

```bash
bash tools/install_git_hooks.sh
```

On GitHub, the workflow will mark the pushed revision red if the smoke test
fails. If you also want GitHub to reject merges until the workflow passes, add
branch protection for the `smoke` workflow in the repository settings.

## Layout

- `tools/SVA_FRONTEND.md`: implementation notes and current limits
- `examples/sva/README.md`: example list and example commands

## Status

This is still prototype code. It is useful for experimentation and regression
testing, but it is not a complete SystemVerilog parser or a complete SVA
implementation.
