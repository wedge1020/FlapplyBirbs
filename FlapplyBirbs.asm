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
%define   TITLESCREEN   0
%define   GAMEPLAY1     1
%define   GAMEPLAY2     2
%define   GAMEPLAY3     3
%define   PLAYER1A      10
%define   PLAYER1B      11
%define   PLAYER1C      12
%define   PLAYER2       20
%define   PLAYER3       30

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
    mov   R0,           255
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
    mov   R0,           511
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
    mov   R0,           767
    out   MAXX,         R0
    mov   R0,           359
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
    ;; select and define TITLESCREEN region
    ;;
    mov   R0,           TITLESCREEN
    out   REGION,       R0
    mov   R0,           256
    out   MINX,         R0
    mov   R0,           256
    out   MINY,         R0
    mov   R0,           256
    out   HOTX,         R0
    mov   R0,           256
    out   HOTY,         R0
    mov   R0,           452
    out   MAXX,         R0
    mov   R0,           430
    out   MAXY,         R0

    wait

    mov   R3,           80
    mov   R4,           160

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
_update:
    in    R0,           FRAME            ; obtain current frame from FrameCounter
    imod  R0,           3                ; modulus by 3

    mov   R1,           _frame_offsets   ; load frame processing routine offsets
    iadd  R1,           R0               ; increment offset based on frame
    mov   R1,           [R1]             ; dereference offset to get actual offset

    mov   R2,           _player_modes
    iadd  R2,           R0

    out   GAMEPAD,      R0               ; select gamepad based on frame
    in    R0,           CONNECTED        ; check if player's gamepad is connected
    jf    R0,           _wait_update     ; if not, do nothing

    mov   R0,           [R2]             ; check player's mode (0->title, 1->gameplay)
    jt    R0,           _update_frame    ; if non-zero: gameplay

    mov   R0,           INP_START        ; player at title screen, check for START
    call  GETINPUT
    igt   R0,           0
    mov   [R2],         R0               ; save mode to memory

    jt    R0,           _player_start    ; play sound if start is pressed

    out   TEXTURE,      TITLESCREEN      ; draw title screen in slice
    out   REGION,       TITLESCREEN
    out   DRAWX,        0
    out   DRAWY,        0
    out   GPUCMD,       DRAW

    jmp  _wait_update

_update_frame:                           ; gameplay in session

    call  R1                             ; call the specific frame processing

_wait_update:
    call  _detect

    wait

    jmp   _update

_player1:
    mov   R2,           PLAYER1A

    out   TEXTURE,      0
    out   REGION,       GAMEPLAY1
    call  _process
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; gamepad 1 / player 2 processing
;;
_player2:
    mov   R2,           PLAYER1A ; PLAYER2A

    out   TEXTURE,      0
    out   REGION,       GAMEPLAY1
    call  _process
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; gamepad 2 / player 3 processing
;;
_player3:
    mov   R2,           PLAYER1A ; PLAYER3A

    out   TEXTURE,      0
    out   REGION,       GAMEPLAY1
    call  _process
    ret

_process:
    out   DRAWX,        0
    out   DRAWY,        0
    out   GPUCMD,       DRAW

    mov   R0,           INP_UP           ; player at title screen, check for START
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
    jmp   _update

_player_modes:
    integer P1_MODE, P2_MODE, P3_MODE

_frame_offsets:
    pointer _player1, _player2, _player3
