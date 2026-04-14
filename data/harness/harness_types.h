/* AUTO-GENERATED from harness preamble */
#pragma once

/* Minimal sliced harness for tif_write.c UAF (use-after-realloc) */
#include <stdint.h>
#include <stdlib.h>

#ifndef tmsize_t
typedef long tmsize_t;
#endif

/* Minimal structs to cover the vulnerable dereference */
struct TIFFDirectory {
    uint32_t td_stripsperimage;
    uint16_t td_fillorder;
};

struct TIFF;
typedef int (*TIFFPreencode)(struct TIFF*, uint16_t);
typedef void (*TIFFPostdecode)(struct TIFF*, uint8_t*, tmsize_t);
typedef int (*TIFFEncodetile)(struct TIFF*, uint8_t*, tmsize_t, uint16_t);
typedef int (*TIFFPostencode)(struct TIFF*);

struct TIFF {
    struct TIFFDirectory* tif_dir;
    TIFFPreencode tif_preencode;
    TIFFPostdecode tif_postdecode;
    TIFFEncodetile tif_encodetile;
    TIFFPostencode tif_postencode;
    uint32_t tif_flags;
    uint8_t* tif_rawdata;
    tmsize_t tif_rawcc;
    uint8_t* tif_rawcp;
};

