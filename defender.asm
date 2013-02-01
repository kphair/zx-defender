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
                
                ; create the interrupt vector table
                ld hl,$8000
                ld de,$8001
                ld bc,$100
                ld (hl),$82
                ldir

                ; set interrupt mode 2 with vector register pointing to new vector table
                ld a,$80
                ld i,a
                im 2
        
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

                call read_keyboard

                call test_break

                call test_reverse
                
                call test_up
                call test_down
	
                call test_thrust
                call ship_friction

                call test_fire
                call set_camera

                ; enable interrupts and return from ISR
                ei
                reti


; Restore interrupt mode, stack pointer and index registers before return to BASIC
;
quit:           di
                ld a,$3f
                ld i,a
                im 1
basic_sp:       ld sp,0
                pop iy
                pop ix
                ei
                ret

prng            proc

                ld hl,(rand0)

                ld a,(prnd)
                ld b,a
                add a,b
                add a,b
                add a,$11
                ld b,a
                sra a
                sra a
                sra a
                xor h
                sra a
                rr h
                rr l
                ld (rand0),hl
                ld a,b
                add a,h
                adc a,l
                ld (prnd),a
        
                retp

                include "sprite_macro.asm"
                include "sprite_code.asm"
                include "input.asm"
                include "view.asm"
                include "fx.asm"
                include "screen.asm"
                include "landscape.asm"
                include "tables.asm"
                include "vars.asm"
                include "charset.asm"
                include "sprite_data.asm"

ends:           dw 0