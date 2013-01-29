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
key_up:         db %11111011, %00000001, ctrl_up        ; Q
key_down:       db %11111101, %00000001, ctrl_down      ; A
key_thrust:     db %01111111, %00001000, ctrl_thrust    ; N
key_fire:       db %01111111, %00000100, ctrl_fire      ; M
key_reverse:    db %11111110, %00000010, ctrl_reverse   ; Z
key_warp:       db %10111111, %00000001, ctrl_warp      ; Enter


test_controls   proc
                ld a,(controls)
                ld (lastcontrols),a

                ld hl,key_up    ; key controls table
                ld b,6          ; number of keys in tables

        check   ld a,(hl)
                in a,(254)
                inc hl
                and (hl)
                inc hl
                jr nz,no_key
                ld a,(controls)
                or (hl)
                ld (controls),a
        
        no_key  djnz check

                retp

