;;
;; flappy.asm: Vircon32 assembly language flappy bird game (with RAM-based
;;             machine code routines)
;;
;; register inventory
;; ------------------
;; R0: temporary (first parameter, return value of subroutines)
;; R1: temporary (second parameter, return value of subroutines)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    jmp   _start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; _start: starting place
;;
;; memory: addresses 0x00000000 - 0x00000007 are being used for the
;;         gamepad input routine
;;
_start:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; store input subroutine at RAM address 0x00000000 (CALL it)
    ;;
    ;; takes R0 as a parameter (current gamepad button)
    ;; returns the result from the IN in R0
    ;;
    ;; using a bitwise iOR, take the baseline 'IN R0, INP_Port' instruction
    ;; and apply the desired button, storing it to memory in the 0x00000005
    ;; address, which is the proper word in the RAM subroutine performing a
    ;; port read (once it gets there, it will be the 'perfect' read due  to
    ;; being set up based on the parameter)
    ;;
    ;; this routine is ideal for placing in a loop that iterates itself  on
    ;; through the desired range of gamepad button ports (0x403-0x40C), not
    ;; needing named separate routines to transact each button
    ;;
    mov   R0,                  0x4E208000 ; machine code: mov  R1, immediate
    mov   [0x00000000],        R0
    mov   R0,                  0x5C000400 ; immediate:    0x5C000400
    mov   [0x00000001],        R0
    mov   R0,                  0x88200000 ; machine code: or   R1, R0
    mov   [0x00000002],        R0
    mov   R0,                  0x4E034000 ; machine code: mov  [immediate], R1
    mov   [0x00000003],        R0
    mov   R0,                  0x00000005 ; immediate:    0x00000005
    mov   [0x00000004],        R0
    mov   R0,                  0x5C000400 ; machine code: in   R0, INP_port
    mov   [0x00000005],        R0
    mov   R0,                  0x10000000 ; machine code: ret
    mov   [0x00000006],        R0
    mov   R0,                  0x00000000 ; machine code: hlt (for safety)
    mov   [0x00000007],        R0

    mov   R0,                  0
    out   GPU_SelectedTexture, R0  ; select texture 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define region 0 (background 0)
    ;;
    mov   R0,                  0
    out   GPU_SelectedRegion,  R0
    out   GPU_RegionMinX,      R0
    out   GPU_RegionMinY,      R0
    out   GPU_RegionHotspotX,  R0
    out   GPU_RegionHotspotY,  R0
    mov   R0,                  128
    out   GPU_RegionMaxX,      R0
    mov   R0,                  256
    out   GPU_RegionMaxY,      R0


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define region 1 (background 1)
    ;;
    mov   R0,                  1
    out   GPU_SelectedRegion,  R0
    mov   R0,                  128
    out   GPU_RegionMinX,      R0
    mov   R0,                  0
    out   GPU_RegionMinY,      R0
    mov   R0,                  128
    out   GPU_RegionHotspotX,  R0
    mov   R0,                  0
    out   GPU_RegionHotspotY,  R0
    mov   R0,                  256
    out   GPU_RegionMaxX,      R0
    mov   R0,                  256
    out   GPU_RegionMaxY,      R0
    
