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

                call showstars
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


                ; decelerate the ship due to friction

                ld a,(thrust+1)
                cpl
                ld l,a
                ld a,(thrust+2)
                ld c,a
                cpl
                ld h,a
                inc hl
                xor a
                bit 7,h
                jr z,thrust_pos
                dec a
thrust_pos:
                ld b,a
                ld a,h
                add hl,hl
                add hl,hl
                ex de,hl
                ld hl,(thrust)
                add hl,de
                ld a,c
                adc a,b
                ld (thrust),hl
                ld (thrust+2),a
        


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
                and 16+32
                out (254),a

                ld a,(ship_dir)
                or a
                ld hl,spr_thrustr
                jr z,thrust_r
                ld hl,spr_thrustl
thrust_r:
                ld (sprexhaust+spr_dsc),hl

                ; Thrust = Thrust + (Thrust + $000300) 

                ld hl,(thrust+1)
                inc h
                inc h
                inc h
                
                ld de,(thrust+0)
                add hl,de
                ld a,(thrust+2)
                adc a,0
                ld (thrust+2),a
                jr z,thrust_ok
                ld hl,0
thrust_ok:                
                ld (thrust+0),hl
                
                xor a
                out (254),a
                jr end_thrust
no_thrust:
                ld hl,spr_idler
                ld a,(ship_dir)
                or a
                jr z,idle_r
                ld hl,spr_idlel
idle_r:
                ld (sprexhaust+spr_dsc),hl
                
end_thrust:     ld hl,(sprexhaust+spr_dsc)
                inc hl
                ld a,r
                xor (hl)
                and 7
                jr nz,exhaust_vis
                inc a
exhaust_vis:
                ld (hl),a

; ************* Test for fire button

                ; Structure for shots table

                shot_timer      equ 0
                shot_scrH       equ 1
                shot_pulse      equ 2
                shot_fade       equ 3
                shot_wipe       equ 4
                
test_fire:      ld a,(controls)
		and ctrl_fire
                jr nz,animate_shots     ; if fire not pressed just animate any existing shots
                ld a,(lastcontrols)
                and ctrl_fire
                jr z,animate_shots      ; only fire new shots if this is a new instance of the control

                ld a,5
                out (254),a

                ld hl,shots_table       ; search for a free slot from 4 available
                ld de,5
                ld b,4

find_fire_slot: ld a,(hl)
                or a
                jr z,fire_slot
                add hl,de
                djnz find_fire_slot
                jp fire_slots_full
                                
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
                inc (ix+shot_timer)
                ld (ix+shot_scrH),h     ; high byte of screen address
                ld (ix+shot_pulse),l    ; low byte of pulse location
                ld (ix+shot_fade),l     ; low byte of fade location
                ld (ix+shot_wipe),l     ; low byte of wipe location

animate_shots:  ld ix,shots_table
                ld b,4
test_shot:      ld a,(ix)
                or a
                jp z,next_shot
                ld e,a

                ld h,(ix+shot_scrH)
                ld l,(ix+shot_pulse)    ; pulse moves one byte every frame

                ld a,l
                and $1f
                jr z,solid_trail        ; if on the last frame, skip the pulse

                cp 1
                jr z,clear_shot

                ld (hl),%01011110
                ld a,h
                and $f8
                rra
                rra
                rra
                or $50
                ld h,a
                ld (hl),$47

                ld a,e
                cp 1
                jr z,shot_cycle         ; If first frame, skip the first solid trail

solid_trail:    ld h,(ix+shot_scrH)     ; reload screen address into HL
                ld l,(ix+shot_pulse)
                dec l
                ld (hl),$ff             ; for every frame other than the first one, draw a solid trail behind the pulse

                ld a,h
                and $f8
                rra
                rra
                rra
                or $50
                ld h,a
                ld a,ixl
                sub LOW shots_table
                srl a
                srl a
                adc a,2
                or $40
                ld (hl),a

fade_trail:     ld a,e
                cp 3                    ; Give the solid trail a couple of frames to be seen
                jr c,shot_cycle
                and 3
                cp 1
                jr z,wipe_trail         ; trail moves three out of every 4 frames
                ld h,(ix+shot_scrH)
                ld l,(ix+shot_fade)
                ld d,HIGH firefade
                ld a,r
                add a,l
                and 7
                add a,LOW firefade
                ld e,a
                ld a,(de)
                ld (hl),a
                inc l
                ld (ix+shot_fade),l

                ld a,h
                and $f8
                rra
                rra
                rra
                or $50
                ld h,a
                ld a,ixl
                sub LOW shots_table
                srl a
                srl a
                adc a,1
;                or $40
                ld (hl),a

                jr shot_cycle

wipe_trail:     ld a,e
                cp 4                    ; don't start wiping the trail until the fade has had a chance to show up
                jr c,shot_cycle
                ld h,(ix+shot_scrH)     ; wipe moves one byte every 4 frames
                ld l,(ix+shot_wipe)
                ld (hl),0
                inc l
                ld (ix+4),l                
                jr shot_cycle

clear_shot:     ld h,(ix+shot_scrH)     ; continue wipe to the edge of screen
                ld l,(ix+shot_wipe)
                ld c,0
                ld (ix),c               ; deactivate this shot
wipe_shot:      ld (hl),c
                inc l
                ld a,l
                and $1f
                jr nz,wipe_shot
                jr next_shot                

shot_cycle:     inc (ix+shot_timer)     ; main counter
                inc (ix+shot_pulse)     ; leave this until last otherwise it messes up the solid trail position

next_shot:      ld de,5
                add ix,de
                dec b
                jp nz,test_shot
fire_slots_full:                
                xor a
                out (254),a

no_fire:

; ************* Add the current thrust level (middle and high bytes) to the ship's x position

; Calculate new landscape offset from ship_x:
; add thrust to ship_x
; add thrust to landscape_ofs
; subtract desired screen edge offset (40 or 216) from ship_x and compare to landscape_ofs
; if <0 then subtract 2 pixels (64) from landscape_ofs
; if >0 then add 2 pixels to landscape_ofs
                

                ld de,(thrust+1)

                ld hl,(sprship+spr_x)
                add hl,de
		ld (sprship+spr_x),hl

                ld hl,(landscape_ofs)
                ld (landscape_lofs),hl
                add hl,de
                ld (landscape_ofs),hl

                ld de,(sprship+spr_x)   ; subtract ship_x
                ex de,hl
                or a
                sbc hl,de
                
                ld de,0

                ld a,(ship_dir)
                or a
                jr z,check_pan_right

                ; ship is facing left, do we need to pan left to bring to the right side of screen
check_pan_left: 
                ld bc,216*32            ; subtract the ship offset from screen edge
                sbc hl,bc
                jr nc,do_pan
                ld de,-3*32
                jr do_pan

                ; ship is facing right, do we need to pan right to bring it to the left side of screen
check_pan_right:                        
                ld bc,40*32             ; subtract the ship offset from screen edge
                sbc hl,bc
                jr c,do_pan
                ld de,3*32
do_pan:
                ld hl,(landscape_ofs)
                add hl,de                
                ld (landscape_ofs),hl
                
                ei
                reti


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
                include "landscape.asm"
                include "charset.asm"
                include "screen.asm"
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