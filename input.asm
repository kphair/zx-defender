; ************  input routines

; Keyboard segments and key masks for the different controls
;
; 1 - 5         %11110111
; 6 - 0         %11101111
; Q - T         %11111011
; Y - P         %11011111
; A - G         %11111101
; H - Enter     %10111111
; CAPS - V      %11111110
; B - Space     %01111111

; control key bit masks
ctrl_up         equ %00000001   ; UP
ctrl_down       equ %00000010   ; DOWN
ctrl_thrust     equ %00000100   ; THRUST
ctrl_fire       equ %00001000   ; FIRE
ctrl_reverse    equ %00010000   ; REVERSE
ctrl_warp       equ %00100000   ; HYPERSPACE

read_keyboard   proc
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


; ************* Test for BREAK
test_break      proc

                ld a,%11111110
                in a,(254)
                and %00000001           ; CAPS
                jp nz,testend
                ld a,%01111111
                in a,(254)
                and %00000001           ; Space
                jp z,quit
        testend retp


; ************* Test for up key pressed
test_up         proc

                ld a,(controls)
                and ctrl_up
		jr nz,up_pressed

                ; if up not pressed then check to see if it previously was and stop moving

                ld a,(sprship+spr_dy+1) 
                rla                     ; test if dy is negative (ship moving up from last keypress)
                jr nc,testend
                ld hl,0                 ; reset dy to 0
                ld (sprship+spr_dy),hl
                jr testend

up_pressed      ld hl,(sprship+spr_y)
                ld de,(sprship+spr_dy)
                ld a,d
                cp -2
                jr z,max_up_vel
                ld de,-$100             ; if DE is 0 then initialise it to $100
max_up_vel:     add hl,de

                ld a,h                  ; Is HL < $2000 (top of play area)
                cp $20
                jr nc,move_up
                ld hl,$2000
                ld de,0
move_up:        ld (sprship+spr_y),hl
                ld hl,-$100
                add hl,de
                ld (sprship+spr_dy),hl
                
        testend retp

; ************* Test for down key pressed
test_down       proc

                ld a,(controls)
                and ctrl_down
		jr nz,down_pressed

                ld a,(sprship+spr_dy+1) 
                or a                    ; test if dy is positive and non-zero (ship moving down)
                jr nc,testend
                ld hl,0                 ; reset dy to 0
                ld (sprship+spr_dy),hl
                jr testend

down_pressed    ld hl,(sprship+spr_y)
                ld de,(sprship+spr_dy)
                ld a,d
                cp 2
                jr z,max_down_vel
                ld de,$100              ; if DE is 0 then initialise it to $100
max_down_vel:   add hl,de

                ld a,h                  ; Is HL < $2000 (top of play area)
                cp $b4
                jr c,move_down
                ld hl,$b400
                ld de,0
move_down:      ld (sprship+spr_y),hl
                ld hl,$100
                add hl,de
                ld (sprship+spr_dy),hl
                
        testend retp


; ************* Test for reverse
test_reverse    proc

                ld a,(controls)
                and ctrl_reverse
                jr z,testend
                ld a,(lastcontrols)     ; only reverse if the control has previously been released
                and ctrl_reverse
                jr nz,testend

                ld a,(ship_dir)
                cpl
                ld (ship_dir),a

        testend retp

; ************* Test for thrust key pressed
test_thrust     proc

                ld a,(controls)
		and ctrl_thrust
		jr z,no_thrust               ; If no thrust then just set the exhaust to idle

                ld a,(rand0)
                inc a
                ld (rand0),a
                ld l,a
                ld h,HIGH noise
                ld a,(hl)
                and $18
                out (254),a

                ld a,(ship_dir)
                or a
                ld hl,spr_thrustr
                jr z,thrustspr_r
                ld hl,spr_thrustl
thrustspr_r:
                ld (sprexhaust+spr_dsc),hl
                
                ; Thrust = Thrust + Thrust/256 + $000300

                ld a,(ship_dir)
                or a
                jr nz,thrust_left

                ; thrust with ship facing right

                ld hl,(thrust+1)
                ld a,h
                rla             ; is thrust pushing left

                inc h
                inc h
                inc h
                
                ld de,(thrust+0)
                add hl,de
                ld a,(thrust+2)
                adc a,0
                ld (thrust+2),a
                jr set_thrust

thrust_left:
                ; thrust with ship facing left
                ; If thrust negative then thrust = thrust + thrust/256 - $000300
                ; otherwise thrust = thrust - thrust/256 - $000300
                
                ld hl,(thrust+1)
                ld bc,$0300
                ld a,h
                rla

                ld de,(thrust+0)
                ld a,(thrust+2)

                jr nc,thrust_left_pos

                add hl,de
                ccf
                sbc a,c
                sbc hl,bc
                sbc a,c
                jr set_thrust

thrust_left_pos:                
                or a
                ex de,hl
                sbc hl,de
                sbc a,c
                sbc hl,bc
                sbc a,c
                ;jr set_thrust

set_thrust:     ld (thrust+2),a
                ld (thrust+0),hl
                
                xor a
                out (254),a
                jr end_thrust

; Thrust is not pressed or has been released. Set the exhaust to idle mode

no_thrust:
                ld hl,spr_idler
                ld a,(ship_dir)
                or a
                jr z,idlespr_r
                ld hl,spr_idlel
idlespr_r:      ld (sprexhaust+spr_dsc),hl
                
end_thrust:     ld hl,(sprexhaust+spr_dsc)      ; random colour for exhaust
                inc hl
                ld a,r
                xor (hl)
                and 7
                jr nz,exhaust_vis
                inc a
exhaust_vis:    ld (hl),a

        testend retp


;************** Apply friction to thrust model so constant deceleration force is applied
ship_friction   proc

                ; apply friction to ship: thrust = thrust - thrust/1024

                ld hl,(thrust+1)
                ld a,h
                rla
                sbc a,a         ; extend sign of H into A
                ld b,a

                add hl,hl
                add hl,hl
                ld d,h
                ld e,l         

                ld hl,(thrust)
                ld a,(thrust+2)
                sbc hl,de
                sbc a,b

                ld (thrust),hl
                ld (thrust+2),a
        
                retp
