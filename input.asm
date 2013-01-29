; ************  input routines

; Keyboard segments and key masks for the different controls
;
; CAPS - V      %11111110
; A - G         %11111101
; Q - T         %11111011
; 1 - 5         %11110111
; 6 - 0         %11101111
; Y - P         %11011111
; H - Enter     %10111111
; B - Space     %01111111

; control key bit masks
ctrl_up         equ %00000001   ; UP
ctrl_down       equ %00000010   ; DOWN
ctrl_thrust     equ %00000100   ; THRUST
ctrl_fire       equ %00001000   ; FIRE
ctrl_reverse    equ %00010000   ; REVERSE
ctrl_warp       equ %00100000   ; HYPERSPACE

controls:       db 0          
lastcontrols:   db 0

; Each key defined by 3 bytes: Keyboard segment mask, key mask within that segment and control bit to set
key_defs:
                db %11111011, %00000001, ctrl_up        ; Q
                db %11111101, %00000001, ctrl_down      ; A
                db %01111111, %00001000, ctrl_thrust    ; N
                db %01111111, %00000100, ctrl_fire      ; M
                db %11111110, %00000010, ctrl_reverse   ; Z
                db %01111111, %00000001, ctrl_reverse   ; Space
                db %10111111, %00000001, ctrl_warp      ; Enter
                db 0

test_controls   proc
                ld a,(controls) 
                ld (lastcontrols),a
                xor a
                ld (controls),a

                ld hl,key_defs  ; table keys defined for controls

        check   ld a,(hl)
                or a
                jr z,endtest
                in a,(254)
                inc hl
                cpl
                and (hl)
                inc hl
                ld c,(hl)
                inc hl
                jr z,check
                ld a,(controls)
                or c
                ld (controls),a
                jr check
        endtest retp

