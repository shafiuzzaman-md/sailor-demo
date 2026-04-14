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

/* Stub that simulates a grow/realloc that invalidates the cached 'td' pointer */
static void _TIFFReserveLargeEnoughWriteBuffer(struct TIFF* tif, tmsize_t cc) {
    (void)cc;
    if (tif && tif->tif_dir) {
        /* Simulate reallocation that frees the old directory without updating aliases */
        free(tif->tif_dir);
        /* Intentionally do NOT nullify tif->tif_dir to create a stale alias scenario */
    }
}

/* Vulnerable function slice containing the exact dereference line */
static tmsize_t sailor_vul_func(struct TIFF* tif, uint32_t tile, void* data, tmsize_t cc) {
    (void)data;
    struct TIFFDirectory* td = tif->tif_dir;  /* local alias to directory */

    /* Simulate the grow call that may invalidate 'td' */
    _TIFFReserveLargeEnoughWriteBuffer(tif, cc);

    /* Keep the exact vulnerable statement from tif_write.c:503 */
    uint16_t sample;
    sample = (uint16_t)(tile / td->td_stripsperimage);
    

    return 0;
}

/* Entry function: strict pass-through calling the vulnerable slice */
tmsize_t TIFFWriteEncodedTile(struct TIFF* tif, uint32_t tile, void* data, tmsize_t cc) {
    return sailor_vul_func(tif, tile, data, cc);
}
