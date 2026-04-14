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
}

s2b() {
    section "Full Query Suite — Standard + SAILOR Custom"
    cat "$DATA/rules_list.txt"
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
    echo -e "${GREEN}\$ ls sa_outputs/libtiff_f324415_vul/${RESET}"
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
    section "Vulnerability Spec (LLM input)"
    echo -e "${GREEN}\$ cat data/vul_spec.json${RESET}"
    echo ""
    python3 -m json.tool < "$DATA/vul_spec.json"
}

s8() {
    section "LLM-Generated Harness: Sliced Vulnerable Source"
    echo -e "${GREEN}\$ cat data/harness/tif_write.c${RESET}"
    echo ""
    cat "$HARNESS/tif_write.c"
}

s5b() {
    section "LLM Agent Loop — Turns, Tool Calls, Refinement"
    echo -e "${GREEN}\$ cat data/llm_transcript.log${RESET}"
    echo ""
    cat "$DATA/llm_transcript.log"
}

s6() {
    section "LLM-Generated Harness: KLEE Driver (symbolic)"
    echo -e "${GREEN}\$ cat data/harness/klee_driver.c${RESET}"
    echo ""
    cat "$HARNESS/klee_driver.c"
}

s6b() {
    section "Reproducer (concrete replay, built with ASan)"
    echo -e "${GREEN}\$ cat data/concrete/reproducer.c${RESET}"
    echo ""
    cat "$CONCRETE/reproducer.c"
}

s7() {
    section "LLM-Generated Harness: Trimmed Types"
    echo -e "${GREEN}\$ cat data/harness/harness_types.h${RESET}"
    echo ""
    cat "$HARNESS/harness_types.h"
}

s9() {
    section "ASan Crash Confirmation"
    echo -e "${GREEN}\$ cat data/concrete/asan_output.txt${RESET}"
    echo ""
    head -30 "$CONCRETE/asan_output.txt"
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

SECTIONS=(s0 s1 s2 s3 s2b s4 s5 s5b s6 s7 s8 s6b s9 s10 s11 s12 s13 s15)
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
