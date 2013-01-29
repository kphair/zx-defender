output_szx "defender.szx", $8100,$8100
export_sym "defender.sym",0

                org $8100

                di   

                ld hl,$7000
                ld de,$7001
                ld bc,$100
                ld (hl),$81
                ldir

                ld a,$70
                ld i,a

                im 2
        
                push iy
                call preshift_sprites
                call unpack_landscape
		call clear_screen
                pop iy

                in a,(254)
                and $1f
                xor $1f
                jr nz, main

                ei

main:           halt
                jp main

                org $8181                
inthandler:

                call erase_landscape
                call draw_landscape
                call showstars

                do_2bsprite(spr0)         ; landers
                do_2bsprite(spr1)
                do_2bsprite(spr2)
                do_2bsprite(spr3)
                do_2bsprite(spr4)
                do_2bsprite(spr5)         ; bombers
                do_2bsprite(spr6)
                do_2bsprite(spr7)         ; swarmers
                do_2bsprite(spr8)
                do_2bsprite(spr9)
                do_2bsprite(spr10)
                do_2bsprite(spr11)
                do_2bsprite(spr12)        ; pod

                ld hl,(sprship+spr_x)
                ld de,-(9*32)
                add hl,de
                ld (sprexhaust+spr_x),hl

                ld hl,(sprship+spr_y)
                ld (sprexhaust+spr_y),hl

                ld iy,sprexhaust
                call place_2bsprite
                ld a,(iy+spr_frm)
                inc a                   ; increment frame number
                cp (ix)                 ; compare to max number of frames in sprite descriptor
                jr c, upd_exhaust
                xor a
upd_exhaust:    ld (iy+spr_frm),a

                ld iy,sprship
                call place_3bsprite
                ld a,(iy+spr_frm)
                inc a                   ; increment frame number
                cp (ix)                 ; compare to max number of frames in sprite descriptor
                jr c,upd_ship
                xor a
upd_ship:       ld (iy+spr_frm),a

                move_lander(spr0)
                move_lander(spr1)
                move_lander(spr2)
                move_lander(spr3)
                move_lander(spr4)
                move_bomber(spr5)
                move_bomber(spr6)
                move_swarmer(spr7)
                move_swarmer(spr8)
                move_swarmer(spr9)
                move_swarmer(spr10)
                move_swarmer(spr11)

sprites_done:   

; ************* Test for up key pressed

test_up:        ld a,251
		in a,(254)
		and %00000001
		jr z,up_pressed
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
                ld de,-$100              ; if DE is 0 then initialise it to $100
max_up_vel:     add hl,de

		ld a,h                ; Is HL < $2000 (top of play area)
                cp $20
                jr nc,move_up
                ld hl,$2000
                ld de,0
move_up:        ld (sprship+spr_y),hl
                ld hl,-$100
                add hl,de
                ld (sprship+spr_dy),hl
                

; ************* Test for down key pressed

test_down:      ld a,253
		in a,(254)
		and %00000001
		jr z,down_pressed

                ld a,(sprship+spr_dy+1) 
                or a                     ; test if dy is positive and non-zero (ship moving down)
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

		ld a,h                ; Is HL < $2000 (top of play area)
                cp $b4
                jr c,move_down
                ld hl,$b400
                ld de,0
move_down:      ld (sprship+spr_y),hl
                ld hl,$100
                add hl,de
                ld (sprship+spr_dy),hl
                
	
; ************* Test for thrust key pressed
        
test_thrust:    ld a,127
		in a,(254)
		and %00001000
		jr nz,no_thrust               ; If no thrust then go to deceleration

                ld a,(rand0)
                ld b,a
                ld a,r
                add a,b
                and 16
                out (254),a

                ld hl,spr_thrustr
                ld (sprexhaust+spr_dsc),hl

                ld hl,(thrust+1)
                ld a,l
                cp $c0
                jr nc,end_thrust

                ld a,h
                add hl,hl
                add hl,hl
                inc h
                ld de,(thrust)
                add hl,de
                adc a,0
                ld (thrust),hl
                ld (thrust+2),a

                xor a
                out (254),a
                jr end_thrust
no_thrust:
                ld hl,spr_idler
                ld (sprexhaust+spr_dsc),hl
                inc hl
                ld a,r
                xor (hl)
                and 7
                ld (hl),a
                
                ld hl,(thrust+1)
                ld a,h
                add hl,hl
                add hl,hl
                ex de,hl
                ld hl,(thrust)
                sbc hl,de
                sbc a,0
                ld (thrust),hl
                ld (thrust+2),a

end_thrust:     ld hl,(sprexhaust+spr_dsc)
                inc hl
                ld a,r
                xor (hl)
                and 7
                ld (hl),a

; ************* Test for fire button

test_fire:      ld a,127
		in a,(254)
		and %00000100
                ex af,af'
                ld a,(lastfire)
                ld b,a
                ex af,af'
                ld (lastfire),a
		jr nz,animate_shots
                
                cp b
                jr z,animate_shots

                ld a,5
                out (254),a

                ld hl,shots             ; search for a free slot from 4 available
                ld de,5
                ld a,(hl)
                or a
                jr z,fire_slot
                add hl,de
                ld a,(hl)
                or a
                jr z,fire_slot
                add hl,de
                ld a,(hl)
                or a
                jr z,fire_slot
                add hl,de
                ld a,(hl)
                or a
                jp nz,fire_slots_full
                                
; get screen address of space in front of ship
fire_slot:      push hl                 ; save HL
                ld hl,(sprship+spr_x)
                ld de,20*32             
                add hl,de               ; add width of sprite
                ld de,(landscape_ofs)
                sbc hl,de               ; calculate offset of sprite relative to screen
                
                ; Shift HL into AHL -> AH = HL/32
                add hl,hl
                rla
                add hl,hl
                rla
                add hl,hl
                rla
                
                ld e,h                  ; keep X position for later

                ld a,(sprship+spr_y+1)  ; get y position
                add a,4
                ld l,a
                ld h,(HIGH scanlinetable)/2
                add hl,hl
                ld a,(hl)
                inc l
                ld h,(hl)
                ld l,a

                ld a,e                  ; get x position again, divide by 8 to get column
                srl a
                srl a
                srl a
                or l
                ld l,a                  ; HL = screen position of space in front of ship
                
                pop ix                  ; restore location of slot
                inc (ix)
                ld (ix+1),h             ; high byte of screen address
                ld (ix+2),l             ; low byte of pulse location
                ld (ix+3),l             ; low byte of trail location
                ld (ix+4),l             ; low byte of wipe location

animate_shots:
                ld ix,shots
                ld b,4
test_shot:
                ld a,(ix)
                or a
                jp z,next_shot

                ld e,(ix)               ; main counter
                inc e
                ld (ix),e

                ld h,(ix+1)
                ld l,(ix+2)             ; pulse moves one byte every frame

                ld a,l
                and $1f
                jr z,last_frame
                ld (hl),%11110000
                ld a,h
                and $f8
                rra
                rra
                rra
                or $50
                ld h,a
                ld (hl),$47

                ld a,e
                cp 2
                jr z,first_frame

                ld h,(ix+1)
                ld l,(ix+2)
last_frame:
                dec l
                ld (hl),$ff

                ld a,h
                and $f8
                rra
                rra
                rra
                or $50
                ld h,a
                ld a,ixl
                rra
                rra
                and 3
                inc a
                or $40
                ld (hl),a
                inc l
first_frame:
                inc l
                ld (ix+2),l
                ld a,l
                and $1f                 
                cp 1
                jr z,clear_shot         ; has it wrapped around edge

check_trail:                
                ld a,e
                and 3
                cp 1
                jr z,do_wipe            ; trail moves three out of every 4 frames
                ld l,(ix+3)
                ld h,(ix+1)
                ld d,HIGH firefade
                ld a,r
                add a,l
                and 7
                add a,LOW firefade
                ld e,a
                ld a,(de)
                ld (hl),a
                inc l
                ld (ix+3),l
                jr next_shot

do_wipe:
                ld l,(ix+4)             ; wipe moves one byte every 4 frames
                ld h,(ix+1)
                ld (hl),0
                inc l
                ld (ix+4),l                

                jr next_shot

clear_shot:     ld l,(ix+4)             ; continue wipe to the edge of screen
                ld h,(ix+1)
                ld c,0
                ld (ix),c               ; deactivate this shot
wipe_shot:      ld (hl),c
                inc l
                ld a,l
                and $1f
                jr nz,wipe_shot
                
next_shot:      ld de,5
                add ix,de
                dec b
                jp nz,test_shot
fire_slots_full:                
                xor a
                out (254),a

no_fire:
                ld hl,(landscape_ofs)
                ld de,(thrust+1)
                add hl,de
		ld (landscape_ofs),hl

                ex de,hl
                add hl,hl
                add hl,hl
                add hl,hl
                ex de,hl
                add hl,de
                ld de,48*32
                add hl,de
		ld (sprship+spr_x),hl
                
                ei
                reti

                include "sprite_macro.asm"
                include "sprite_code.asm"
                include "landscape.asm"
                include "charset.asm"
                include "screen.asm"
                include "sprite_data.asm"

rand0:          dw 13*73-1
rand1:          dw 23*97-1

thrustnoise:    db 0

shots:          db 0,0,0,0,0
                db 0,0,0,0,0
                db 0,0,0,0,0
                db 0,0,0,0,0
lastfire:       db 0                    ; used to keep track of the last state of the fire button

                align 16
firefade:       db %00010001, %11010111, %00001001, %01000101, %10101000, %00011001, %01100001, %01100101

