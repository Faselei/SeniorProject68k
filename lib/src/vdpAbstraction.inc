;===============================================================================
;vdpAbstraction.inc
;===============================================================================
;defines vdp ports and constants for other assembly files
;-------------------------------------------------------------------------------

;VDP registers
VDP_DATA equ $00C00000
VDP_CTRL equ $00C00004
VDP_HVCOUNTER equ $00C00008

;VDP constants
VDP_REGION_NTSC equ 1
VDP_REGION_PAL equ 2

;User DMA constants
DMA_TYPE_MAIN equ 0
DMA_TYPE_FILL equ 1
DMA_TYPE_COPY equ 2

;VDP data sizes in bytes
VRAM_SIZE    equ 65536
CRAM_SIZE    equ 128
VSRAM_SIZE   equ 80

;VDP command constants
VRAM_WRITE_CMD equ $40000000
CRAM_WRITE_CMD equ $C0000000
VSRAM_WRITE_CMD equ $40000010
VRAM_READ_CMD equ $00000000
CRAM_READ_CMD equ $00000040
VSRAM_READ_CMD equ $00000020
VRAM_DMA_CMD equ $40000080
CRAM_DMA_CMD equ $C0000080
VSRAM_DMA_CMD equ $40000090
;///////////////////////////////////////////////////////////////////////////////
