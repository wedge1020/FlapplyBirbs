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
%define   GAMEPLAY      1
%define   PLAYER1       10
%define   PLAYER2       20
%define   PLAYER3       30

    jmp   _start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; _detect: subroutine to detect which gamepads are connected
;;
_detect:
    push  R2
    mov   R2,           [CONNECTION]  ; variable storing connected gamepads
    mov   R0,           0             ; gamepad ID

_detect_loop:
    out   GAMEPAD,      R0            ; select gamepad
    in    R1,           CONNECTED     ; check if connected    
    shl   R1,           R0            ; shift left by gamepad ID
    or    R2,           R1            ; bitwise iOR connections register
    iadd  R0,           1             ; increment gamepad ID
    ilt   R0,           3             ; if gamepad ID is less than 3 ...
    jt    R0,           _detect_loop  ; ... perform another iteration

    mov   [CONNECTION], R2            ; store updated CONNECTION variable
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
    mov   R0,           0x4E208000 ; machine code: mov  R1, immediate
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
    ;; select and define region 0 (background 0)
    ;;
    mov   R0,           0
    out   REGION,       R0
    out   MINX,         R0
    out   MINY,         R0
    out   HOTX,         R0
    out   HOTY,         R0
    mov   R0,           128
    out   MAXX,         R0
    mov   R0,           256
    out   MAXY,         R0

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;; select and define region 1 (background 1)
    ;;
    mov   R0,           1
    out   REGION,       R0
    mov   R0,           128
    out   MINX,         R0
    mov   R0,           0
    out   MINY,         R0
    mov   R0,           128
    out   HOTX,         R0
    mov   R0,           0
    out   HOTY,         R0
    mov   R0,           256
    out   MAXX,         R0
    mov   R0,           256
    out   MAXY,         R0

    wait

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
;; frame 3: sound update
;; frame 4: gamepad detection and screen refreshing
;;
_update:
    in    R0,           FRAME            ; obtain current frame from FrameCounter
    imod  R0,           5                ; modulus by 5
    mov   R1,           _frame_offsets   ; load frame processing routine offsets
    iadd  R1,           R0               ; increment offset based on frame
    mov   R1,           [R1]             ; dereference offset to get actual offset
    out   GAMEPAD,      R0               ; select gamepad based on frame
    call  R1                             ; call the specific frame processing
    wait
    jmp   _update

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; gamepad 0 / player 1 processing
;;
_frame_0:

    in    R0,           CONNECTED        ; check if player's gamepad is connected
    jf    R0,           _frame_0_end     ; if not, do nothing

    mov   R0,           [P1_MODE]        ; determine player mode (0, non-zero)
    jt    R0,           _frame_0_update  ; if non-zero -> gameplay, update frame

    mov   R0,           INP_START        ; player at title screen, check for START
    call  GETINPUT
    igt   R0,           0
    mov   [P1_MODE],    R0               ; save mode to P1_MODE

    jt    R0,           _player_start    ; play sound if start is pressed

    out   TEXTURE,      TITLESCREEN      ; draw title screen in slice
    out   REGION,       TITLESCREEN
    out   DRAWX,        0
    out   DRAWY,        0
    out   GPUCMD,       DRAW

_frame_0_end:
    ret

_frame_0_update:                         ; game in session

    out   TEXTURE,      GAMEPLAY
    out   REGION,       GAMEPLAY
    out   DRAWX,        0
    out   DRAWY,        0
    out   GPUCMD,       DRAW

    out   REGION,       PLAYER1

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; gamepad 1 / player 2 processing
;;
_frame_1:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; gamepad 2 / player 3 processing
;;
_frame_2:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; sound processing
;;
_frame_3:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; basic service routine: clear the screen, check the gamepads
;;
_frame_4:
    mov   R0,           0x00000000
    out   GPUCMD,       CLS
    call  _detect
    ret

_player_start:
    jmp   _update

_title:
    mov   R0,           0
    out   TEXTURE,      0
    out   REGION,       0
    out   DRAWX,        0
    out   DRAWY,        0
    out   GPUCMD,       DRAW
    hlt

_frame_offsets:
    pointer _frame_0, _frame_1, _frame_2, _frame_3, _frame_4
