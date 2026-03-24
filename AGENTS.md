# Repository Guidelines

This document provides guidance for agentic coding agents operating in this repository.

## Project Overview

This is a formal verification toolkit for SystemVerilog Assertions (SVA). The `formal` script is the top-level CLI entrypoint that forwards into `tools/formal.py`. Core implementation lives in `tools/`:
- `sva_lower.py`: Lowers a supported SVA subset into Yosys-compatible formal code
- `sva_sby.py`: Stages `.sby` projects and selects the backend (sby or ebmc)
- `SVA_FRONTEND.md`: Documents the supported SVA subset and frontend limitations

Tests live in `tools/` as executable `unittest` scripts. Examples in `examples/sva/` serve as the regression corpus. Generated runs land in `build/formal_runs/` and must not be committed.

## Build, Test, and Development Commands

### Running Tests

```bash
# Run all tests (byte-compile + unit tests + live sby/ebmc checks)
bash tools/smoke_test.sh

# Run a single test file
python3 tools/test_sva_lower.py
python3 tools/test_formal.py
python3 tools/test_sva_sby.py
python3 tools/test_gui.py

# Run a specific test method
python3 -m unittest tools.test_sva_lower.SvaLowerTests.test_lowers_assert_assume_cover
```

### Running the Formal Wrapper

```bash
# Install the wrapper command once
bash tools/install_bin_link.sh

# Run on an existing .sby project
sva2sby examples/sva/assert_raw_delay_pass.sby

# Run direct RTL input with options
sva2sby path/to/design.sv --top top_name --mode bmc --depth 20

# Run with waveform viewing
sva2sby examples/sva/assert_raw_delay_pass.sby -waves

# Run prove mode
sva2sby examples/sva/assert_goto_pass.sby prove
```

### Pre-commit Hooks

```bash
# Enable the local push gate
bash tools/install_git_hooks.sh
```

## Project Structure

```
/tool/formal_tools/e_oss_cad/enhanced-oss-cad/
├── formal               # Top-level CLI wrapper
├── tools/
│   ├── formal.py        # CLI entrypoint and argument handling
│   ├── sva_lower.py     # SVA-to-Yosys lowering logic
│   ├── sva_sby.py       # .sby staging and backend selection
│   ├── gui.py           # Web GUI for formal results
│   ├── test_*.py        # Unit tests (executable)
│   ├── smoke_test.sh    # Main test gate
│   ├── SVA_FRONTEND.md  # SVA subset documentation
│   └── install_git_hooks.sh
├── examples/sva/        # Regression corpus (.sby and .sv files)
│   ├── assert_*_pass.sby    # Expected pass cases
│   ├── assert_*_fail.sby    # Expected fail cases
│   └── cover_*_*.sby        # Coverage cases
└── build/formal_runs/   # Generated outputs (gitignored)
```

## Coding Style & Naming Conventions

### Python Style

- Use 4-space indentation
- Use `snake_case` for functions, modules, and variables
- Use `PascalCase` for classes
- Use explicit type hints where practical (e.g., `list[str]`, `Path | None`)
- Use `from __future__ import annotations` for modern type syntax
- Keep modules under 1500 lines; split large files

### Import Ordering

```python
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

import third_party_module

from local_module import function
```

Order: future imports, standard library (alphabetically), third-party, local imports.

### Module Docstrings

Use short module docstrings (1-3 lines):

```python
"""Lower a small SVA subset and run sby on the lowered output."""
```

### Function Naming

Use clear helper names:
- `default_workdir_for_input()` - good: describes purpose
- `normalize_argv()` - good: verb-first
- `resolve_cli_path()` - good: verb-first
- Avoid: `process()`, `handle()`, `run()` (too vague)

### Error Handling

- Raise `ValueError` with descriptive messages for user input errors
- Include context in error messages: `f"sva_sby: malformed section header '{line}'"`
- Use `sys.stderr` for user-facing error output
- Return exit codes: `0` for success, `1` for assertion failure, `2` for usage/setup errors

### Dataclasses

Use `@dataclass` for structured data:

```python
@dataclass
class PropertyDef:
    name: str
    clock: str
    disable: str | None
    sequence: FixedSequence | PatternSequence | None = None
```

Use `frozen=True` for immutable data:

```python
@dataclass(frozen=True)
class DelayRange:
    min: int
    max: int
```

### Shell Scripts

Use POSIX-friendly Bash with strict mode:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
```

## Testing Guidelines

### Test File Organization

Tests live in `tools/test_*.py` as executable `unittest` scripts. Each test file follows this structure:

```python
#!/usr/bin/env python3
"""Tests for [module being tested]."""

from __future__ import annotations

import unittest

from module_under_test import function


class ModuleTests(unittest.TestCase):
    def test_expected_behavior(self) -> None:
        # Test implementation
        pass


if __name__ == "__main__":
    unittest.main()
```

### Test Naming

Name test methods `test_<behavior>` or `test_<condition>_<expected_result>`:

- `test_lowers_assert_assume_cover` - good: describes behavior
- `test_source_requires_ebmc_for_full_sva_operators` - good: condition + result
- `test_zero_cycle_sequence_assert_is_allowed` - good: specific case

### Assertions

Use specific assertions:

```python
self.assertIn("expected_text", output)
self.assertEqual(result, expected)
self.assertTrue(args.waves)
self.assertRaisesRegex(ValueError, "error pattern", function, arg)
```

### Adding New Tests

1. Add tests to the nearest `tools/test_*.py` file
2. When changing user-visible lowering or staging behavior, add matching examples in `examples/sva/`
3. Run `bash tools/smoke_test.sh` before pushing

### Example Naming

Name examples descriptively by behavior and expected outcome:
- `assert_feature_pass.sby` - assertion that should pass
- `assert_feature_fail.sby` - assertion that should fail
- `cover_feature_miss.sv` - coverage property that shouldn't hit

## Commit & Pull Request Guidelines

### Commit Messages

Use short imperative subjects (50 chars or less):

```
Add smoke CI and pre-push hook
Clean wrapper surface and expand SVA examples
Add project GUI and wrapper usability updates
```

Follow the pattern:
1. Start with a verb (Add, Fix, Update, Refactor, Remove)
2. Keep the subject focused on one change
3. Avoid mixing unrelated changes in one commit

### Pull Requests

PRs should:
1. Describe the affected flow (`formal`, lowering, staging, or examples)
2. List the commands you ran to verify
3. Include representative CLI output when behavior changes
4. Note if screenshots are needed (usually unnecessary for this repository)

## SVA Lowering Limitations

The prototype lowerer supports a narrow subset. For operators outside this subset, the `ebmc` backend is used automatically.

### Supported Subset

- Named sequences with fixed delays: `sequence NAME; TERM ##N TERM; endsequence`
- Ranged-delay sequences: `TERM ##[M:N] TERM`
- Properties with `@(posedge clk)` and optional `disable iff (expr)`
- Implication operators: `|->` (overlapping) and `|=>` (non-overlapping)
- Bounded repetition in consequents: `A[*M:N]`, `A[->N]`, `A[=N]`
- Event functions: `$rose()`, `$fell()`, `$stable()`, `$changed()`
- Assertion kinds: `assert property`, `assume property`, `cover property`

### Unsupported (Use ebmc Backend)

- Nested/composed properties
- Multi-clock properties
- Unbounded goto/nonconsecutive repetition without depth limit
- Multiple modules in one file (lowering handles single module only)
- `within`, `throughout`, `intersect`, `first_match`, `until`, `s_eventually`, etc.

## Environment Notes

- Tools assume `sby` (SymbiYosys) is on PATH
- Optional `ebmc` for full-SVA operator support
- Wave traces use `gtkwave` if available, otherwise `xdg-open`/`open`
- Generated outputs go to `build/formal_runs/` (gitignored)
