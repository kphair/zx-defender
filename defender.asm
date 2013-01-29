; Comment the following if you want the output to be a code block that can
; be LOADed across the serial port
snapshot equ true

;-------------
;
; Program code starts at $8000

                org $8000

if def snapshot
        ; output an SZX snapshot file
        output_szx "defender.szx", $8200,$8200
        output_bin "defender.bin", $8200, ends-$8200
else
        org .-9
        ; output an Interface 1 stream header
        output_bin "defender.code", ., ends-.
        db 3            ; Type = CODE
        dw ends-.-8     ; Block length
        dw .+6          ; Block origin
        dw $ffff, $ffff ; Variable store and autorun for BASIC programs
endif


export_sym "defender.sym",0

                org $8200

                di   
                push ix
                push iy
                ld (basic_sp+1),sp
                
                ld hl,$8000
                ld de,$8001
                ld bc,$100
                ld (hl),$82
                ldir

                ld a,$80
                ld i,a

                im 2
        
                push iy
                call preshift_sprites
                call unpack_landscape
		call clear_screen

                in a,(254)
                and $1f
                xor $1f
                jr nz, main

                ei

main:           halt
                jp main

                org $8282                
inthandler:

                call show_stars
                call erase_landscape
                call draw_landscape

                do_2bsprite(spr0)         ; landers
                do_2bsprite(spr1)
                do_2bsprite(spr2)
                do_2bsprite(spr3)
                do_2bsprite(spr4)
                do_2bsprite(spr5)         ; bombers
                do_2bsprite(spr6)
                do_2bsprite(spr7)         ; swarmers
                do_2bsprite(spr8)
                do_3bsprite(spr9)
                do_3bsprite(spr10)
                do_3bsprite(spr11)
                do_2bsprite(spr12)        ; pod


                ; Display the ship exhaust and main sprite
                ; ship_offset is positive is ship is facing right, negative if left
                ; ship_offset is the desired pixel offset from the edge of the screen
                ; 

                ld a,(ship_dir)
                or a
                jr nz,ship_left

                ; Ship is facing right

                ld hl,spr_shipr         ; set ship sprite facing right
                ld (sprship+spr_dsc),hl
                ld de,-9*32             ; position exhaust 9 pixels left of the ship
                jr ship_right

ship_left:      ld hl,spr_shipl         ; set ship sprite facing left
                ld (sprship+spr_dsc),hl
                ld de,17*32             ; position exhaust 17 pixels right of the ship

ship_right:
                ; set exhaust x position
                ld hl,(sprship+spr_x) 
                add hl,de
                ld (sprexhaust+spr_x),hl
                ; set exhaust y position
                ld hl,(sprship+spr_y)
                ld (sprexhaust+spr_y),hl
                ; draw the exhaust
                ld iy,sprexhaust
                call place_2bsprite
                ld a,(iy+spr_frm)
                inc a                   ; increment frame number
                cp (ix)                 ; compare to max number of frames in sprite descriptor
                ld b,a                  ; reset to 0 if no carry
                sbc a,a
                and b
                ld (iy+spr_frm),a

                ld iy,sprship
                call place_3bsprite
                ld a,(iy+spr_frm)
                inc a                   ; increment frame number
                cp (ix)                 ; compare to max number of frames in sprite descriptor
                ld b,a
                sbc a,a
                and b
                ld (iy+spr_frm),a

                move_lander(spr0)
                move_lander(spr1)
                move_lander(spr2)
                move_lander(spr3)
                move_lander(spr4)
                move_bomber(spr5)
                move_bomber(spr6)
                move_lander(spr7)
                move_lander(spr8)
                move_baiter(spr9)
                move_baiter(spr10)
                move_baiter(spr11)

sprites_done:   

                call test_controls

; ************* Test for BREAK

                ld a,%11111110
                in a,(254)
                and %00000001           ; CAPS
                jp nz,test_reverse
                ld a,%01111111
                in a,(254)
                and %00000001           ; Space
                jp z,quit

; ************* Test for reverse

test_reverse:   ld a,(controls)
                and ctrl_reverse
                jr z,test_up
                ld a,(lastcontrols)     ; only reverse if the control has previously been released
                and ctrl_reverse
                jr nz,test_up

                ld a,(ship_dir)
                cpl
do_reverse:     ld (ship_dir),a

; ************* Test for up key pressed

test_up:        ld a,(controls)
                and ctrl_up
		jr nz,up_pressed

                ; if up not pressed then check to see if it previously was and stop moving

                ld a,(sprship+spr_dy+1) 
                rla                     ; test if dy is negative (ship moving up from last keypress)
                jr nc,test_down
                ld hl,0                 ; reset dy to 0
                ld (sprship+spr_dy),hl
                jr test_down

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
                

; ************* Test for down key pressed

test_down:      ld a,(controls)
                and ctrl_down
		jr nz,down_pressed

                ld a,(sprship+spr_dy+1) 
                or a                    ; test if dy is positive and non-zero (ship moving down)
                jr nc,test_thrust
                ld hl,0                 ; reset dy to 0
                ld (sprship+spr_dy),hl
                jr test_thrust

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
                
	
; ************* Test for thrust key pressed

test_thrust:    
                ld a,(controls)
		and ctrl_thrust
		jr z,no_thrust               ; If no thrust then turn the exhaust down

                ld a,(rand0)
                inc a
                ld (rand0),a
                ld l,a
                ld h,HIGH noise
                ld a,(hl)
                and 16+8
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

no_thrust:
                ld hl,spr_idler
                ld a,(ship_dir)
                or a
                jr z,idlespr_r
                ld hl,spr_idlel
idlespr_r:
                ld (sprexhaust+spr_dsc),hl
                
end_thrust:     ld hl,(sprexhaust+spr_dsc)      ; change the attribute of the exhaust sprite to random colour
                inc hl
                ld a,r
                xor (hl)
                and 7
                jr nz,exhaust_vis
                inc a
exhaust_vis:
                ld (hl),a


                ; apply friction to ship thrust
                ; thrust = thrust - (thrust + $000100)/256

                ld a,(thrust+1)         ; middle byte
                cpl
                ld l,a
                ld a,(thrust+2)         ; high byte
                ld c,a
                cpl
                ld h,a
                inc hl                  ; HL = -(middle and high byte)
                xor a
                bit 7,h
                jr z,thrust_pos
                cpl
thrust_pos:
                ld b,a
                ld a,h
                add hl,hl
                add hl,hl
                ex de,hl
                ld hl,(thrust)          ; low and middle byte
                add hl,de
                ld a,c
                adc a,b
                ld (thrust),hl
                ld (thrust+2),a
        


                call test_fire
                call set_camera


                ; enable interrupts and return from ISR

                ei
                reti


                ; Restore interrupt mode, stack pointer and index registers before return to BASIC

quit:           di
                ld a,$3f
                ld i,a
                im 1
basic_sp:       ld sp,0
                pop iy
                pop ix
                ei
                ret

                include "sprite_macro.asm"
                include "sprite_code.asm"
                include "input.asm"
                include "view.asm"
                include "fx.asm"
                include "screen.asm"
                include "landscape.asm"
                include "charset.asm"
                include "screen_data.asm"
                include "sound_data.asm"
                include "sprite_data.asm"

                align 16
firefade:       dg ---#---###-#-###----#--#-#---#-##-#-#------##--#-##----#-##--#-#

rand0:          dw 13*73-1
rand1:          dw 23*97-1

shots_table     db 0,0,0,0,0
                db 0,0,0,0,0
                db 0,0,0,0,0
                db 0,0,0,0,0

thrustnoise:    db 0

ship_dir:       db $00          ; right = $00, left = $ff

ends:           dw 0