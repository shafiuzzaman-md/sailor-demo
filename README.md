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

Press ENTER to advance through the sections. Each one displays a real file
from the libtiff experiment with colored terminal output.

Navigation (not shown on screen so it stays clean for live presentations):
ENTER / `n` = next, `b` = back, `q` = quit, `<number>` = jump to that section.

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

| Section | Shows |
|---------|-------|
| Title + Overview | Pipeline phases, demo target |
| Input — Project Config | `libtiff_config.sh` |
| How to Run SAILOR | Two-command invocation |
| CodeQL Rule | `CWE-416_UseAfterRealloc.ql` query body |
| CodeQL Findings | `findings.jsonl` count + first entry |
| Vulnerability Spec | Per-finding JSON fed to the LLM |
| LLM Agent Loop | Turn-by-turn transcript with KLEE-driven refinement |
| KLEE Driver (symbolic) | `klee_driver.c` — symbolic entry |
| Trimmed Types | `harness_types.h` — pared-down structs |
| Sliced Vulnerable Source | `tif_write.c` |
| Reproducer | `reproducer.c` — concrete replay driver |
| ASan Crash Confirmation | Real crash trace against `libtiff.a` |
| Structured Result | `result.json` |
| Fuzz Harness | `fuzz_harness.c` |
| Fuzz Result | libFuzzer crash + summary |
| All Confirmed Bugs | `confirmed_summary.tsv` |
| Summary | Input & output artifact overview |

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
