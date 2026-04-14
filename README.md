# SAILOR Demo (~10 minutes)

A self-contained, portable demo of **SAILOR** — Static Analysis Informed
LLM-Orchestrated Symbolic Execution — a fully automated vulnerability discovery
pipeline for C/C++ codebases.

This package bundles real artifacts from a libtiff experiment so the demo runs
on any machine without needing the full SAILOR repository.

## Requirements

- Bash
- Python 3 (for pretty-printing JSON)

That's it — no compilers, no KLEE, no build steps. The demo only displays
pre-generated artifacts.

## Quick Start

```bash
git clone <this-repo>
cd sailor-demo
bash run_demo.sh
```

Press ENTER to advance through 11 sections. Each section displays a real file
from the libtiff experiment with colored terminal output.

## Files

| Path | Purpose |
|------|---------|
| `run_demo.sh` | Interactive terminal demo (ENTER to advance) |
| `DEMO_SCRIPT.md` | Full written walkthrough with speaker commentary |
| `data/libtiff_config.sh` | The project config SAILOR consumes |
| `data/CWE-416_UseAfterRealloc.ql` | CodeQL rule that flagged the bug |
| `data/findings.jsonl` | CodeQL static-analysis findings (1,491 entries) |
| `data/vul_spec.json` | Single-finding spec (LLM input) |
| `data/llm_transcript.log` | Agent-loop transcript: prompts, tool calls, KLEE-driven refinement |
| `data/confirmed_summary.tsv` | All 21 confirmed libtiff bugs |
| `data/harness/` | LLM-generated harness (what goes *into* KLEE/ASan) |
| `data/harness/tif_write.c` | Sliced vulnerable source |
| `data/harness/klee_driver.c` | Symbolic driver fed to KLEE |
| `data/harness/harness_types.h` | Trimmed struct definitions |
| `data/harness/build.sh` | Build glue |
| `data/concrete/` | Concrete validation outputs |
| `data/concrete/reproducer.c` | Concrete replay driver built with ASan |
| `data/concrete/asan_output.txt` | Crash trace against unmodified `libtiff.a` |
| `data/concrete/result.json` | Structured per-bug result |
| `data/fuzz/` | Same bug, independently reproduced by libFuzzer |
| `data/fuzz/fuzz_harness.c` | libFuzzer entry point |
| `data/fuzz/fuzz_asan_output.txt` | libFuzzer crash trace |
| `data/fuzz/ossfuzz_result.json` | Fuzzer result summary |

## Demo Structure

| # | Section | Time | What You Show |
|---|---------|------|---------------|
| 1 | Title + Overview | 1 min | Pipeline diagram |
| 2 | Input | 1 min | Project config, two commands to run |
| 3 | CodeQL Output | 1.5 min | findings.jsonl, sample finding |
| 3b | CodeQL Rule | 1 min | CWE-416_UseAfterRealloc.ql query |
| 4 | LLM Harness | 2 min | Sliced tif_write.c |
| 5 | Reproducer | 1 min | KLEE-generated reproducer.c |
| 6 | ASan Confirmation | 1.5 min | Full crash trace |
| 7 | Result JSON | 0.5 min | Structured result |
| 8 | Fuzz Reproduction | 1 min | fuzz_harness.c, libFuzzer crash |
| 9 | Bug Report | 1 min | REPORT.md |
| 10 | Summary Table | 0.5 min | confirmed_summary.tsv |
| 11 | Artifact Tree | 0.5 min | Directory listing |

## Featured Bug

**heap-use-after-free** in `tif_write.c:503` (CWE-416)

`TIFFWriteEncodedTile` caches a pointer to `tif->tif_dir` in a local variable
`td`, then calls `_TIFFReserveLargeEnoughWriteBuffer`, which may `realloc`
(and thus `free`) the directory. The subsequent `td->td_stripsperimage`
dereference reads freed memory.

This is a real, confirmed vulnerability in libtiff, reproduced against the
unmodified `libtiff.a` and independently re-triggered by libFuzzer.

## Key Talking Points

- **Fully automated** — two commands, no manual analysis
- **Real bugs** — confirmed against the real, unmodified library `.a` (no sliced source in the final link)
- **Double-verified** — ASan replay + independent libFuzzer confirmation
- **Scalable** — 128 parallel workers, projects from 10K to 500K+ LoC
- **394 unique bugs** found across 9 real-world C/C++ projects
