# Presenter Notes

One line per section. What to say out loud while the screen shows the file.

| Section | Say this |
|---|---|
| Title + Overview | SAILOR pipeline, demo target libtiff f324415 |
| Input — Project Config | One script per target, names the repo + commit + build flags |
| How to Run SAILOR | Two commands, fully automated, no manual analysis |
| CodeQL Rule | SAILOR ships custom queries — metadata up top, intra-proc pattern below, select clause emits the finding message |
| Full Query Suite | 13 stock CodeQL C/C++ queries + 21 SAILOR custom = 34; actual-fire counts show most findings came from our extensions |
| CodeQL Findings | In a real run these all land in `sa_outputs/<project>/`; 1,491 findings, one per line |
| Vulnerability Spec | Each finding becomes one self-contained JSON the LLM consumes — facts merged in from the fact pack, llm_hints are static boilerplate |
| LLM Agent Loop | Agent calls tools (ReadSAContext, GatherCode, WriteHarness, WriteDriver, CompileSlice); Turn 6 rewrites the driver after KLEE flags an unsatisfiable klee_assume — this is the refinement loop |
| KLEE Driver | Symbolic entry — `klee_make_symbolic`, `klee_assume`; KLEE explores paths where `tif->tif_dir` gets reallocated and the stale `td` on line 503 is dereferenced |
| Trimmed Types | LLM pares libtiff's opaque TIFF / TIFFDirectory structs down to just the fields the slice touches |
| Sliced Vulnerable Source | The sliced function — realloc site + the stale-pointer dereference |
| Reproducer | Once KLEE finds a crashing path it emits a ktest; SAILOR bakes those bytes into this standalone C driver for ASan replay |
| ASan Crash Confirmation | Confirmed against the real, unmodified `libtiff.a` — no sliced source in the final link |
| Structured Result | Single JSON per confirmed bug; consumed by downstream tooling and the summary |
| Fuzz Harness | Independent channel — same bug re-triggered via libFuzzer from scratch |
| Fuzz Result | libFuzzer finds the crash too — two independent confirmations of the same bug |
| All Confirmed Bugs | 21 confirmed concrete bugs in libtiff alone |
| Summary | Input vs output package; one bug ships with spec + harness + concrete artifacts + fuzz artifacts |
