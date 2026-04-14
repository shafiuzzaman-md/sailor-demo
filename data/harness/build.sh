#!/bin/bash
# Build instructions for this reproducer

gcc -fsanitize=address -fno-omit-frame-pointer -g -O0 \
    reproducer.c smart_stubs.c tif_write.c \
    /app/artifacts/libtiff_f324415_vul/verify_data/upstream/asan_build/libtiff/libtiff.a \
    -o reproducer_bin -lm -lpthread -lz

ASAN_OPTIONS='detect_leaks=0:halt_on_error=1:print_stacktrace=1' ./reproducer_bin