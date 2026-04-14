#!/bin/bash
# SAILOR Interactive Demo (standalone, self-contained)
# Run: bash run_demo.sh
# Navigation (not shown on screen):
#   ENTER or n  = next        b  = back
#   q            = quit        <number> = jump to section

set -e
DEMO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DATA="$DEMO_ROOT/data"
HARNESS="$DATA/harness"
CONCRETE="$DATA/concrete"
FUZZ="$DATA/fuzz"

BOLD='\033[1m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

section() {
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}$1${RESET}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${RESET}"
    echo ""
}

DEMO_SPEC="1310_tif_write.c_503_sailor_cpp_cwe-416-use-after-realloc"

# ─── Section functions (each renders one screen) ───

s0() {
    section "SAILOR: Static Analysis Informed LLM-Orchestrated Symbolic Execution"
    echo "A fully automated vulnerability discovery pipeline for C/C++ codebases."
    echo ""
    echo "Phases: CodeQL → Spec Gen → LLM Harness → KLEE → ASan (+ optional libFuzzer)"
    echo ""
    echo "Demo target: libtiff (commit f324415)"
}

s1() {
    section "Input — Project Config"
    echo -e "${GREEN}\$ cat data/libtiff_config.sh${RESET}"
    echo ""
    cat "$DATA/libtiff_config.sh"
}

s2() {
    section "How to Run SAILOR"
    echo -e "${GREEN}# Step 1: Prepare (CodeQL scan + spec generation + LLVM bitcode)${RESET}"
    echo '$ ./sailor_prepare.sh f324415/libtiff_f324415_vul'
    echo ""
    echo -e "${GREEN}# Step 2: Run the LLM agent pipeline${RESET}"
    echo '$ LLM_MODEL=gpt-5 ./sailor.sh f324415/libtiff_f324415_vul'
    echo ""
    echo "(Both steps are fully automated — no manual intervention needed.)"
}

s3() {
    section "CodeQL Rule (CWE-416 Use-After-Realloc)"
    echo -e "${GREEN}\$ cat data/CWE-416_UseAfterRealloc.ql${RESET}"
    echo ""
    head -60 "$DATA/CWE-416_UseAfterRealloc.ql"
    echo ""
    echo -e "${YELLOW}(rule continues — $(wc -l < "$DATA/CWE-416_UseAfterRealloc.ql") lines total)${RESET}"
}

s4() {
    section "Static Analysis Output (CodeQL findings)"
    echo -e "${YELLOW}(In a real SAILOR run these all land in sa_outputs/<project>/)${RESET}"
    echo ""
    cat <<'EOF'
codeql-results.sarif   codeql_rule_time.csv   codeql_time.log
compile_commands.json  detected_cwes.txt      fact_pack.json
findings.csv           findings.json          findings.jsonl
run_meta.json          timing/
EOF
    echo ""
    echo -e "${GREEN}\$ wc -l data/findings.jsonl${RESET}"
    wc -l < "$DATA/findings.jsonl"
    echo ""
    echo -e "${GREEN}\$ head -1 data/findings.jsonl | python3 -m json.tool | head -20${RESET}"
    echo ""
    head -1 "$DATA/findings.jsonl" | python3 -m json.tool | head -20
}

s5() {
    section "Vulnerability Spec (LLM input — findings + facts merged)"
    echo -e "${YELLOW}Each CodeQL finding is turned into a single self-contained JSON${RESET}"
    echo -e "${YELLOW}that the LLM agent consumes.${RESET}"
    echo ""
    echo -e "${GREEN}\$ cat data/vul_spec.json${RESET}"
    echo ""
    python3 -m json.tool < "$DATA/vul_spec.json"
}

s8() {
    section "LLM-Generated Harness: Sliced Vulnerable Source"
    echo "Spec id: ${DEMO_SPEC}"
    echo "Bug: heap-use-after-free in tif_write.c:503 (CWE-416)"
    echo ""
    echo -e "${GREEN}\$ cat data/harness/tif_write.c${RESET}"
    echo ""
    cat "$HARNESS/tif_write.c"
}

s5b() {
    section "LLM Agent Loop — Turns, Tool Calls, and Refinement"
    echo -e "${YELLOW}SAILOR feeds the spec to an LLM agent that calls tools (ReadSAContext,${RESET}"
    echo -e "${YELLOW}GatherCode, WriteHarness, WriteDriver, CompileSlice). KLEE feedback${RESET}"
    echo -e "${YELLOW}drives refinement — here Turn 6 rewrites the driver after KLEE flags${RESET}"
    echo -e "${YELLOW}an unsatisfiable klee_assume from Turn 4.${RESET}"
    echo ""
    echo -e "${GREEN}\$ cat data/llm_transcript.log${RESET}"
    echo ""
    cat "$DATA/llm_transcript.log"
}

s6() {
    section "LLM-Generated Harness: KLEE Driver (symbolic)"
    echo -e "${YELLOW}Symbolic entry point — KLEE explores paths that may realloc${RESET}"
    echo -e "${YELLOW}tif->tif_dir and then dereference the stale 'td' on line 503.${RESET}"
    echo ""
    echo -e "${GREEN}\$ cat data/harness/klee_driver.c${RESET}"
    echo ""
    cat "$HARNESS/klee_driver.c"
}

s6b() {
    section "Reproducer (concrete replay, built with ASan)"
    echo -e "${YELLOW}Once KLEE finds a crashing path it emits a ktest. SAILOR then${RESET}"
    echo -e "${YELLOW}bakes those bytes into this standalone C driver for ASan replay.${RESET}"
    echo ""
    echo -e "${GREEN}\$ cat data/concrete/reproducer.c${RESET}"
    echo ""
    cat "$CONCRETE/reproducer.c"
}

s7() {
    section "LLM-Generated Harness: Trimmed Types"
    echo -e "${YELLOW}The LLM pares libtiff's opaque TIFF / TIFFDirectory structs${RESET}"
    echo -e "${YELLOW}down to just the fields the slice actually touches.${RESET}"
    echo ""
    echo -e "${GREEN}\$ cat data/harness/harness_types.h${RESET}"
    echo ""
    cat "$HARNESS/harness_types.h"
}

s9() {
    section "ASan Crash Confirmation"
    echo -e "${GREEN}\$ cat data/concrete/asan_output.txt${RESET}"
    echo ""
    head -30 "$CONCRETE/asan_output.txt"
    echo ""
    echo -e "${RED}▲ heap-use-after-free CONFIRMED against the real, unmodified libtiff.a!${RESET}"
}

s10() {
    section "Structured Result"
    echo -e "${GREEN}\$ cat data/concrete/result.json${RESET}"
    echo ""
    python3 -m json.tool < "$CONCRETE/result.json" 2>/dev/null || cat "$CONCRETE/result.json"
}

s11() {
    section "Independent Fuzz Reproduction — Harness"
    echo -e "${GREEN}\$ cat data/fuzz/fuzz_harness.c${RESET}"
    echo ""
    cat "$FUZZ/fuzz_harness.c"
}

s12() {
    section "Independent Fuzz Reproduction — Result"
    echo -e "${GREEN}\$ cat data/fuzz/ossfuzz_result.json${RESET}"
    python3 -m json.tool < "$FUZZ/ossfuzz_result.json"
    echo ""
    echo -e "${GREEN}\$ head -15 data/fuzz/fuzz_asan_output.txt${RESET}"
    head -15 "$FUZZ/fuzz_asan_output.txt"
}

s13() {
    section "All Confirmed Bugs (libtiff)"
    echo -e "${GREEN}\$ cat data/confirmed_summary.tsv${RESET}"
    echo ""
    column -t -s$'\t' < "$DATA/confirmed_summary.tsv" 2>/dev/null || cat "$DATA/confirmed_summary.tsv"
}

s15() {
    section "Summary — SAILOR Input & Output Package"
    echo -e "${BOLD}Input (per target project):${RESET}"
    echo "  - Project config           (libtiff_config.sh)"
    echo "  - Source tree + build info"
    echo "  - CodeQL rule pack         (CWE-416_UseAfterRealloc.ql, ...)"
    echo ""
    echo -e "${BOLD}Pipeline artifacts (per finding):${RESET}"
    echo "  - CodeQL findings          (findings.jsonl)"
    echo "  - Vulnerability spec       (vul_spec.json)        ← LLM input"
    echo "  - Agent-loop transcript    (llm_transcript.log)"
    echo ""
    echo -e "${BOLD}Harness (LLM-generated):${RESET}"
    echo "  - Sliced vulnerable src    (tif_write.c)"
    echo "  - KLEE driver — symbolic   (klee_driver.c)"
    echo "  - Trimmed types            (harness_types.h)"
    echo ""
    echo -e "${BOLD}Concrete validation (per confirmed bug):${RESET}"
    echo "  - Replay driver            (reproducer.c)"
    echo "  - ASan crash trace         (asan_output.txt)"
    echo "  - Structured result        (result.json)"
    echo ""
    echo -e "${BOLD}Independent fuzz reproduction:${RESET}"
    echo "  - Fuzz harness + result    (fuzz_harness.c, fuzz_asan_output.txt)"
}

SECTIONS=(s0 s1 s2 s3 s4 s5 s5b s6 s7 s8 s6b s9 s10 s11 s12 s13 s15)
TOTAL=${#SECTIONS[@]}
i=0

while true; do
    clear
    "${SECTIONS[$i]}"
    echo ""
    read -r input
    case "$input" in
        q|Q) clear; exit 0 ;;
        b|B) (( i > 0 )) && i=$((i-1)) ;;
        ''|n|N) (( i < TOTAL-1 )) && i=$((i+1)) || { clear; exit 0; } ;;
        [0-9]|[0-9][0-9])
            if (( input >= 0 && input < TOTAL )); then i=$input; fi ;;
    esac
done
