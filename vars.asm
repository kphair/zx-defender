controls:       db 0          
lastcontrols:   db 0
rand0:          dw 13*73-1
rand1:          dw 23*97-1
thrustnoise:    db 0
ship_dir:       db $00          ; right = $00, left = $ff

camera_x:	dw 0		; Current offset
camera_lastx:	dw 0		; Last offset (for erase run or last frame differencing)

thrust:         db 0,0,0

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

