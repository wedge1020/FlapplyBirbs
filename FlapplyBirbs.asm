;;
;; FlapplyBirbs.asm: Vircon32 assembly language flappy bird game (with RAM-
;;                   based machine code routines)
;;
;; register inventory
;; ------------------
;; R0: temporary (first parameter, return value of subroutines)
;; R1: temporary (second parameter, return value of subroutines)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; preprocessor defines
;;
%define   FRAME         TIM_FrameCounter
%define   GPUCMD        GPU_Command
%define   CLS           GPUCommand_ClearScreen
%define   DRAW          GPUCommand_DrawRegion
%define   TEXTURE       GPU_SelectedTexture
%define   REGION        GPU_SelectedRegion
%define   DRAWX         GPU_DrawingPointX
%define   DRAWY         GPU_DrawingPointY
%define   MINX          GPU_RegionMinX
%define   MINY          GPU_RegionMinY
%define   HOTX          GPU_RegionHotspotX
%define   HOTY          GPU_RegionHotspotY
%define   MAXX          GPU_RegionMaxX
%define   MAXY          GPU_RegionMaxY
%define   GETINPUT      0x00000000
%define   CONNECTION    0x00000008
%define   GAMEPAD       INP_SelectedGamepad
%define   CONNECTED     INP_GamepadConnected
%define   INP_LEFT      2
%define   INP_RIGHT     3
%define   INP_UP        4
%define   INP_DOWN      5
%define   INP_START     6
%define   INP_A         7
%define   INP_B         8
%define   INP_X         9
%define   INP_Y         10
%define   INP_L         11
%define   INP_R         12
%define   P1_MODE       0x00000009
%define   P2_MODE       0x0000000A
%define   P3_MODE       0x0000000B
%define   P1_X          0x0000000C
%define   P2_X          0x0000000D
%define   P3_X          0x0000000E
%define   P1_Y          0x0000000F
%define   P2_Y          0x00000010
%define   P3_Y          0x00000011
%define   P1_DELAY      0x00000012
%define   P2_DELAY      0x00000013
%define   P3_DELAY      0x00000014
%define   TITLESCREEN   0
%define   GAMEPLAY1     1
%define   GAMEPLAY2     2
%define   GAMEPLAY3     3
%define   BLANK         4
%define   GETREADY      5
%define   PLAYER1A      10
%define   PLAYER1B      11
%define   PLAYER1C      12
%define   PLAYER2       20
%define   PLAYER3A      30
%define   PLAYER3B      31
%define   PLAYER3C      32

    jmp   _start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; _detect: subroutine to detect which gamepads are connected
;;
_detect:
    push  R2
    push  R3                          ; loop counter
    mov   R2,           [CONNECTION]  ; variable storing connected gamepads
    mov   R3,           0             ; gamepad ID

_detect_loop:
    out   GAMEPAD,      R3            ; select gamepad
    in    R1,           CONNECTED     ; check if connected    
    shl   R1,           R0            ; shift left by gamepad ID
    or    R2,           R1            ; bitwise iOR connections register
    iadd  R3,           1             ; increment gamepad ID
    mov   R0,           R3            ; copy R3 into R0 for comparison
    ilt   R0,           3             ; if gamepad ID is less than 3 ...
    jt    R0,           _detect_loop  ; ... perform another iteration

    mov   [CONNECTION], R2            ; store updated CONNECTION variable
    pop   R3
    pop   R2
    ret

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
    mov   R0,           0x4E200000 ; machine code: mov  R1, immediate
    mov   [0x00000000], R0
    mov   R0,           0x5C000400 ; immediate:    0x5C000400
    mov   [0x00000001], R0
    mov   R0,           0x88200000 ; machine code: or   R1, R0
    mov   [0x00000002], R0
    mov   R0,           0x4E034000 ; machine code: mov  [immediate], R1
    mov   [0x00000003], R0
    mov   R0,           0x00000005 ; immediate:    0x00000005
    mov   [0x00000004], R0
    mov   R0,           0x5C000400 ; machine code: in   R0, INP_port
    mov   [0x00000005], R0
    mov   R0,           0x10000000 ; machine code: ret
    mov   [0x00000006], R0
    mov   R0,           0x00000000 ; machine code: hlt (for safety)
    mov   [0x00000007], R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; initialize gamepad CONNECTION variable
    ;;
    mov   R0,           0
    mov   [CONNECTION], R0

    mov   R0,           0
    out   TEXTURE,      R0  ; select texture 0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define GAMEPLAY1 region
    ;;
    mov   R0,           GAMEPLAY1
    out   REGION,       R0
    out   MINX,         R0
    out   MINY,         R0
    out   HOTX,         R0
    out   HOTY,         R0
    mov   R0,           211
    out   MAXX,         R0
    mov   R0,           359
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define GAMEPLAY2 region
    ;;
    mov   R0,           GAMEPLAY2
    out   REGION,       R0
    mov   R0,           256
    out   MINX,         R0
    mov   R0,           0
    out   MINY,         R0
    mov   R0,           256
    out   HOTX,         R0
    mov   R0,           0
    out   HOTY,         R0
    mov   R0,           467
    out   MAXX,         R0
    mov   R0,           359
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define GAMEPLAY3 region
    ;;
    mov   R0,           GAMEPLAY3
    out   REGION,       R0
    mov   R0,           512
    out   MINX,         R0
    mov   R0,           0
    out   MINY,         R0
    mov   R0,           512
    out   HOTX,         R0
    mov   R0,           0
    out   HOTY,         R0
    mov   R0,           723
    out   MAXX,         R0
    mov   R0,           359
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define BLANK region
    ;;
    mov   R0,           BLANK
    out   REGION,       R0
    mov   R0,           768
    out   MINX,         R0
    mov   R0,           360
    out   MINY,         R0
    mov   R0,           768
    out   HOTX,         R0
    mov   R0,           360
    out   HOTY,         R0
    mov   R0,           980
    out   MAXX,         R0
    mov   R0,           720
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define GETREADY region
    ;;
    mov   R0,           GETREADY
    out   REGION,       R0
    mov   R0,           260
    out   MINX,         R0
    mov   R0,           430
    out   MINY,         R0
    mov   R0,           260
    out   HOTX,         R0
    mov   R0,           430
    out   HOTY,         R0
    mov   R0,           452
    out   MAXX,         R0
    mov   R0,           494
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define PLAYER1A region
    ;;
    mov   R0,           PLAYER1A
    out   REGION,       R0
    mov   R0,           0
    out   MINX,         R0
    mov   R0,           360
    out   MINY,         R0
    mov   R0,           0
    out   HOTX,         R0
    mov   R0,           360
    out   HOTY,         R0
    mov   R0,           40
    out   MAXX,         R0
    mov   R0,           390
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define PLAYER1B region
    ;;
    mov   R0,           PLAYER1B
    out   REGION,       R0
    mov   R0,           42
    out   MINX,         R0
    mov   R0,           360
    out   MINY,         R0
    mov   R0,           42
    out   HOTX,         R0
    mov   R0,           360
    out   HOTY,         R0
    mov   R0,           82
    out   MAXX,         R0
    mov   R0,           390
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define PLAYER3A region
    ;;
    mov   R0,           PLAYER3A
    out   REGION,       R0
    mov   R0,           0
    out   MINX,         R0
    mov   R0,           422
    out   MINY,         R0
    mov   R0,           0
    out   HOTX,         R0
    mov   R0,           422
    out   HOTY,         R0
    mov   R0,           40
    out   MAXX,         R0
    mov   R0,           450
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define PLAYER3B region
    ;;
    mov   R0,           PLAYER3B
    out   REGION,       R0
    mov   R0,           42
    out   MINX,         R0
    mov   R0,           422
    out   MINY,         R0
    mov   R0,           42
    out   HOTX,         R0
    mov   R0,           422
    out   HOTY,         R0
    mov   R0,           82
    out   MAXX,         R0
    mov   R0,           450
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define TITLESCREEN region
    ;;
    mov   R0,           TITLESCREEN
    out   REGION,       R0
    mov   R0,           256
    out   MINX,         R0
    mov   R0,           360
    out   MINY,         R0
    mov   R0,           256
    out   HOTX,         R0
    mov   R0,           360
    out   HOTY,         R0
    mov   R0,           452
    out   MAXX,         R0
    mov   R0,           430
    out   MAXY,         R0

    wait

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; initialize player X, Y coordinates (all players)
    ;;
    mov   R3,           80
    mov   [P1_X],       R3
    mov   R3,           292
    mov   [P2_X],       R3
    mov   R3,           506
    mov   [P3_X],       R3
    mov   R4,           160
    mov   [P1_Y],       R4
    mov   [P2_Y],       R4
    mov   [P3_Y],       R4

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; initialize player modes (0 for title screen)
    ;;
    mov   R0,           0
    mov   [P1_MODE],    R0
    mov   [P2_MODE],    R0
    mov   [P3_MODE],    R0

    mov   R6,           0
    mov   R7,           GAMEPLAY1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; _update: routine to manage player view and input (this is JMPed to, not CALLed)
;;
;; this is essentially the main game loop
;;
;; as the  game is essentially up  to 3 concurrent copies  going at once,
;; depending on the frame, different types of processing will occur:
;;
;; frame 0: gamepad 0/player 1
;; frame 1: gamepad 1/player 2
;; frame 2: gamepad 2/player 3
;;
;; gamepad detection, sound update, other tasks occur each frame
;;
;; R3: X coordinate
;; R4: Y coordinate
;; R5: frame (0-2)
;; R6: gameplay theme (texture)
;; R7: gameplay region (0-3)
;; R8: slice X coordinate
;;
_update:
    in    R5,           FRAME            ; obtain current frame from FrameCounter
    imod  R5,           3                ; modulus by 3

    mov   R1,           _frame_offsets   ; load frame processing routine offsets
    iadd  R1,           R5               ; increment offset based on frame
    mov   R1,           [R1]             ; dereference offset to get actual offset

    mov   R2,           P1_MODE
    iadd  R2,           R5

    mov   R8,           _player_slices   ; _player_slices has the starting X value
    iadd  R8,           R5
    mov   R8,           [R8]

_check:
    out   GAMEPAD,      R5               ; select gamepad based on frame
    in    R0,           CONNECTED        ; check if player's gamepad is connected
    jf    R0,           _blank_slice     ; if not, do nothing (skip this next part)

    mov   R0,           [R2]             ; check player's mode (0->title, 1->gameplay)
    jt    R0,           _update_frame    ; if non-zero: proceed to gameplay logic

    mov   R0,           INP_START        ; player at title screen, check for START
    call  GETINPUT                       ; call custom RAM machine code routine
    igt   R0,           0                ; R0 being positive means the key is pressed
    mov   [R2],         R0               ; save mode to memory

    jt    R0,           _player_start    ; play sound if start is pressed

_boop:
    out   TEXTURE,      0                ; draw title screen in slice
    out   REGION,       GAMEPLAY1
    out   DRAWX,        R8
    out   DRAWY,        0
    out   GPUCMD,       DRAW

    in    R1,           FRAME            ; get frame counter value
	;mov   R0,           R1
	;imod  R0,           3
	;ieq   R0,           2
	;jt    R0,           _display_title
    cif   R1

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; y = 8 * sin (12 * PI/180 * framecounter) * amplify
    ;;
    mov   R0,           1
    cif   R0
    fmul  R0,           3.14159
    fdiv  R0,           180.0
    fmul  R0,           3.0
    fmul  R0,           R1
    sin   R0
    fmul  R0,           8.0
	fmul  R0,           1.25              ; slope multiplier

	mov   R1,           R0
	fgt   R1,           7.0
	jf    R1,           _title_lower
	mov   R0,           7.0

_title_lower:   
	mov   R1,           R0
	flt   R1,           -7.0
	jf    R1,           _title_convert
	mov   R0,           -7.0

_title_convert:
    cfi   R0

_display_title:
    out   REGION,       TITLESCREEN
    iadd  R8,           8
    out   DRAWX,        R8
	out   DRAWY,        R0
    out   GPUCMD,       DRAW

    ;mov   R0,           R5
    ;iadd  R0,           48
    ;out   TEXTURE,      -1
    ;out   REGION,       R0
    ;out   DRAWX,        500
    ;out   GPUCMD,       DRAW

    jmp  _wait_update

_update_frame:                           ; gameplay in session

    out   TEXTURE,      R6               ; select the current background and display it
    out   REGION,       R7
    out   DRAWX,        R8
    out   DRAWY,        0
    out   GPUCMD,       DRAW

    mov   R0,           P1_DELAY         ; check for player delay
    iadd  R0,           R5
    mov   R0,           [R0]
    cib   R0
    jt    R0,           _get_ready    

_main_frame:
    call  R1                             ; call the specific frame processing
    call  _process
    ;call  _detect

    mov   R0,           P1_X
    iadd  R0,           R5
    mov   [R0],         R3               ; store current player X to memory

    mov   R0,           P1_Y
    iadd  R0,           R5
    mov   [R0],         R4               ; store current player Y to memory

_wait_update:
    wait
    jmp   _update

_blank_slice:
    out   REGION,       BLANK            ; blank the slice
    out   DRAWX,        R8
    out   DRAWY,        0
    out   GPUCMD,       DRAW

    mov   R0,           0
    mov   [R2],         R0               ; reset slice

    jmp   _wait_update

_get_ready:
    mov   R0,           P1_DELAY         ; get player delay
    iadd  R0,           R5
    mov   R1,           [R0]
    cif   R1

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; y = 8 * sin (12 * PI/180 * delayvalue) * amplify
    ;;
    mov   R0,           1
    cif   R0
    fmul  R0,           3.14159
    fdiv  R0,           180.0
    fmul  R0,           12.0
    fmul  R0,           R1
    sin   R0
    fmul  R0,           8.0
	fmul  R0,           1.125            ; amplify the wave

	mov   R1,           R0
	fgt   R1,           8.0
	jf    R1,           _ready_lower
	mov   R0,           8.0

_ready_lower:   
	mov   R1,           R0
	flt   R1,           -8.0
	jf    R1,           _ready_convert
	mov   R0,           -8.0

_ready_convert:
    cfi   R0

    out   REGION,       GETREADY
    iadd  R8,           8
    out   DRAWX,        R8
    mov   R1,           128
    iadd  R1,           R0
    out   DRAWY,        R1
    out   GPUCMD,       DRAW

    mov   R0,           P1_DELAY         ; adjust player delay
    iadd  R0,           R5
    mov   R1,           [R0]
    isub  R1,           1
    mov   [R0],         R1

    jmp   _wait_update

_player1:
    mov   R2,           PLAYER1A
    mov   R3,           [P1_X]           ; load current player X from memory
    mov   R4,           [P1_Y]           ; load current player Y from memory
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; gamepad 1 / player 2 processing
;;
_player2:
    mov   R2,           PLAYER1A ; PLAYER2A
    mov   R3,           [P2_X]
    mov   R4,           [P2_Y]
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; gamepad 2 / player 3 processing
;;
_player3:
    mov   R2,           PLAYER3A ; PLAYER3A
    mov   R3,           [P3_X]
    mov   R4,           [P3_Y]
    ret

_process:
    mov   R0,           INP_DOWN         ; control active player
    call  GETINPUT
    igt   R0,           0
    jf    R0,           _player_not_up
    
    isub  R4,           5

    iadd  R2,           1
    out   REGION,       R2

    jmp   _player_done

_player_not_up:
    iadd  R4,           3

    out   REGION,       R2

_player_done:
    out   DRAWX,        R3
    out   DRAWY,        R4
    out   GPUCMD,       DRAW
    ret

_player_start:
    mov   R0,           P1_DELAY         ; set up player delay
    iadd  R0,           R5

    mov   R1,           60               ; delay for 1 second
    mov   [R0],         R1               ; save to memory

    jmp   _update

_player_slices:
    integer 0, 214, 427

_frame_offsets:
    pointer _player1, _player2, _player3
