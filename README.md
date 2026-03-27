<div align="center">

# ⚡ sva2sby

**Source-to-source SVA lowering for the open-source formal verification stack**

[![Smoke Test](https://img.shields.io/badge/tests-passing-brightgreen)](#smoke-test)
[![Python 3.10+](https://img.shields.io/badge/python-3.10%2B-blue)](#prerequisites)
[![License](https://img.shields.io/badge/license-MIT-green)](#)

*Write concurrent SVA assertions → run them through SymbiYosys — no commercial frontend required.*

</div>

---

## The Problem

Open-source formal verification tools are strong at RTL-level checks, but concurrent SVA support is uneven. In practice you're stuck with two bad options:

1. **Rewrite assertions by hand** into lower-level formal logic
2. **Switch to a commercial frontend** for the whole project

## The Solution

**sva2sby** takes a middle path:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Your .sv    │     │  sva_lower   │     │  Generated   │     │    sby /     │
│  with SVA    │────▶│  lowering    │────▶│  formal RTL  │────▶│  formal run  │
│  assertions  │     │  engine      │     │  + monitors  │     │              │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
```

- **Parses** a bounded SVA subset from your SystemVerilog source
- **Lowers** it into synthesizable monitor logic + `assert`/`assume`/`cover`
- **Stages** existing `.sby` projects without modifying your source tree
- **Runs** the result through SymbiYosys with zero manual rewriting

---

## ✨ Features

### SVA Lowering Engine

| SVA Construct | Support | Notes |
|:---|:---:|:---|
| Implication `\|->` / `\|=>` | ✅ | Overlapping and non-overlapping |
| Fixed delay `##N` | ✅ | Direct lowering |
| Ranged delay `##[M:N]` | ✅ | Bounded |
| Bounded repetition `[*M:N]` | ✅ | Consecutive, with chained tails |
| Goto repetition `[->N]` | ✅ | Depth-bounded automaton |
| Nonconsecutive repetition `[=N]` | ✅ | Depth-bounded automaton |
| `$rose` / `$fell` / `$stable` / `$changed` | ✅ | Lowered with sampled helper state |
| `throughout` | ✅ | Guard over exact-delay rhs sequence |
| Named `sequence` / `property` | ✅ | Single-clock subset |
| Parameterized properties | ✅ | Formal arguments with substitution |
| `default clocking` | ✅ | One-line and multiline forms |
| `disable iff` | ✅ | Inline and module-level default |
| `assert` / `assume` / `cover property` | ✅ | Named, anonymous, labeled, multiline |
| Inline `[file ...]` blocks | ✅ | Lowered in-place within `.sby` |

### .sby Wrapper (sva_sby)

- **Transparent staging** — copies and lowers source files into a generated workdir; originals are never modified
- **Task & engine support** — respects `[tasks]`, per-task `[options]`, and per-task `[engines]` sections
- **Engine override** — `--engine "smtbmc yices"` replaces engine lines across all tasks
- **Verific stripping** — `--compat` / `--strip-verific` comments out `read -verific` lines for OSS compatibility
- **Bind rewriting** — `bind target checker (.*)` is expanded into explicit instantiation inside the target module
- **Formal read marking** — scripts referencing lowered files get `-formal` added to their `read` commands
- **Depth auto-expansion** — prove tasks using bounded-eventual monitors have their depth automatically doubled for k-induction soundness

### CLI Wrapper (formal)

```bash
# Run directly on a .sv file
sva2sby design.sv --top top_name --mode bmc --depth 20

# Run on an existing .sby project
sva2sby project.sby prove

# Compatibility mode for Verific-gated inputs
sva2sby project.sby --compat

# Open waveform traces after the run
sva2sby -waves project.sby

# Override the formal engine
sva2sby project.sby --engine "smtbmc yices"

# Select backend explicitly
sva2sby project.sby --backend sby     # default
sva2sby project.sby --backend ebmc    # use ebmc directly
sva2sby project.sby --backend auto    # auto-detect based on SVA operators
```

### Web GUI

```bash
sva2sby gui --port 8080 --open-browser
```

A local web interface at `http://127.0.0.1:8080` with:

- 📁 **File browser** — navigate project directories and pick `.sv`/`.sby` inputs
- 🚀 **Job launcher** — configure backend, mode, depth, engine, and tasks from a form
- 📊 **Live log tailing** — stream stdout/stderr as jobs run
- 📦 **Artifact viewer** — preview generated `.sby`, lowered `.sv`, traces, and other outputs
- ⏹️ **Job management** — cancel running jobs, review history
- 🗂️ **Example picker** — load bundled examples from `examples/sva/` with one click

### Testing Infrastructure

- **76 unit tests** across 4 test modules
- **Smoke test** (`bash tools/smoke_test.sh`) — bytecode compilation, full unit suite, and live wrapper run
- **CI pipeline** — `.github/workflows/smoke.yml` runs on every push and PR
- **Pre-push hook** — `.githooks/pre-push` gates pushes on the smoke test

---

## 🚀 Quick Start

### Prerequisites

- Python 3.10+
- `sby` (SymbiYosys) on `PATH`

### Install

```bash
# Clone the repo
git clone https://github.com/yusuf-ern/sva2sby.git && cd sva2sby

# Install the command link into your tool bin
bash tools/install_bin_link.sh

# Enable the pre-push hook
bash tools/install_git_hooks.sh
```

### First Run

```bash
# Run a passing assertion example
sva2sby examples/sva/assert_raw_delay_pass.sby

# Run a direct .sv file
sva2sby examples/sva/assert_raw_delay_pass.sv

# Run with a specific task
sva2sby examples/sva/assert_raw_delay_tasks.sby prove

# Launch the GUI
sva2sby gui
```

### Smoke Test

```bash
bash tools/smoke_test.sh
```

---

## 📂 Repository Layout

```
sva2sby/
├── formal                         # Shell entrypoint (-> tools/formal.py)
├── tools/
│   ├── formal.py                  # CLI wrapper with subcommands (sby, gui)
│   ├── sva_lower.py               # SVA -> formal RTL lowering engine
│   ├── sva_sby.py                 # .sby staging, backend selection, ebmc driver
│   ├── gui.py                     # Local web GUI server
│   ├── smoke_test.sh              # Full smoke test script
│   ├── install_bin_link.sh        # Install sva2sby command
│   ├── install_git_hooks.sh       # Install pre-push hook
│   ├── test_sva_lower.py          # Lowering engine tests
│   ├── test_sva_sby.py            # Wrapper/staging tests
│   ├── test_gui.py                # GUI helper tests
│   └── test_formal.py             # CLI wrapper tests
├── examples/sva/                  # Regression corpus (55+ files)
│   ├── assert_*                   # Assertion pass/fail examples
│   ├── assume_*                   # Assumption + assertion combos
│   ├── cover_*                    # Cover hit/miss examples
│   └── README.md                  # Example catalog
├── .github/workflows/smoke.yml    # CI pipeline
└── .githooks/pre-push             # Local push gate
```

---

## 📋 Example Corpus

The `examples/sva/` directory serves as a regression corpus with **55+ files** covering:

| Category | Examples |
|:---|:---|
| Raw delay properties | `assert_raw_delay_pass`, `assert_raw_delay_fail`, `assert_raw_delay_tasks` |
| Named sequences | `assert_named_delay_pass/fail` |
| Nested sequences | `assert_nested_sequence_pass/fail` |
| Bounded repetition | `assert_repeat_tail_pass/fail` |
| Goto repetition `[->]` | `assert_goto_pass/fail` |
| Nonconsecutive `[=]` | `assert_nonconsecutive_pass/fail` |
| `disable iff` | `assert_disable_iff_pass/fail` |
| Multiple assertions | `assert_multi_all_pass`, `assert_multi_one_fail` |
| Assume + Assert | `assume_assert_named_delay`, `assume_assert_overlap` |
| Cover properties | `cover_named_delay_hit/miss`, `cover_disable_iff_hit/miss`, `cover_same_cycle_hit` |

Each `.sv` file has a matching `.sby` file for wrapper-mode testing.

---

## ⚙️ How It Works

### Direct .sv Mode

```
design.sv -> sva_lower (parse + lower) -> lowered.sv -> generate run.sby -> sby
```

1. Parse SVA constructs from the source
2. Lower into explicit monitor registers + `assert`/`assume`/`cover` under `ifdef FORMAL
3. Generate a temporary `.sby` with the lowered source
4. Run `sby` on the generated project

### .sby Wrapper Mode

```
project.sby -> parse sections -> stage sources -> lower SVA in copies -> rewrite .sby -> sby
```

1. Parse the original `.sby` into structured sections
2. Stage all source files into a generated workdir (`build/formal_runs/`)
3. Lower SVA in the staged copies (originals untouched)
4. Rewrite script paths, add `-formal` flags, expand bind statements
5. Run `sby` on the generated `.sby`

---

## ⚠️ Current Limits

This is a bounded-subset tool, not a full SVA frontend. Known limits:

- Multi-clock properties
- Nested/composed properties beyond the current bounded subset
- General unbounded `[->]` and `[=]` (currently depth-bounded)
- Multiple `default clocking` / `default disable iff` declarations
- `throughout` with ranged-delay rhs sequences
- Full multi-module lowering in one pass
- `within`, `intersect`, `first_match`, `until`, `s_eventually`, `nexttime`

---

## 🗺️ Roadmap

**Priority SVA operators:**
`within` · `intersect` · `first_match` · `until` / `until_with` · `accept_on` / `reject_on` · `nexttime` / `s_nexttime` · `s_eventually`

**Infrastructure:**
Exact unbounded automata for `[->]`/`[=]` · broader `throughout` coverage · scoped default clocking · multi-clock support · stronger bind handling

---

## 📄 License

MIT
