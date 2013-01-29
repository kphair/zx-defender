do_2bsprite     macro(sprp)
        
                ld iy,sprp
                
                call place_2bsprite
        
                ld a,(iy+spr_frm)
                inc a                   ; increment frame number
                cp (ix)                 ; compare to max number of frames in sprite descriptor
                jr c, no_reset
                xor a
no_reset:       ld (iy+spr_frm),a

                ld hl,(sprp+spr_x)
                ld de,(sprp+spr_dx)
                add hl,de
                ld (sprp+spr_x),hl
        
                ld hl,(sprp+spr_y)
                ld de,(sprp+spr_dy)
                add hl,de
                ld a,h
                cp 32
                jr nc,nowrapup
                add a,152
                ld h,a
                jr nowrapdown
nowrapup:       cp 184
                jr c,nowrapdown
                sub 152
                ld h,a
nowrapdown:     ld (sprp+spr_y),hl
                mend

do_3bsprite     macro(sprp)
        
                ld iy,sprp

                call place_3bsprite
        
                ld a,(iy+spr_frm)
                inc a                   ; increment frame number
                cp (ix)                 ; compare to max number of frames in sprite descriptor
                jr c, no_reset
                xor a
no_reset:       ld (iy+spr_frm),a

                ld hl,(sprp+spr_x)
                ld de,(sprp+spr_dx)
                add hl,de
                ld (sprp+spr_x),hl
        
                ld hl,(sprp+spr_y)
                ld de,(sprp+spr_dy)
                add hl,de
                ld a,h
                cp 32
                jr nc,nowrapup
                add a,160
                ld h,a
                jr nowrapdown
nowrapup:       cp 192
                jr c,nowrapdown
                sub 160
                ld h,a
nowrapdown:     ld (sprp+spr_y),hl
                mend


; A newly arrived lander will have a random velocity towards the ground
; if the ground gets closer than 32 pixels the vertical speed is set to the same value as the horizontal speed
; so that it moves upwards in a diagonal
; if it is moving upwards and the ground is 32 pixels or more away vertical speed is set to 0
; if vertical speed is 0 and height off ground is 32 or more pixels, vertical speed is set to absolute horizontal speed

move_lander     macro(sprp)

                ; only update direction if on frame 1
                ld a,(sprp+spr_frm)
                or a
                jr nz,end_move

                ld hl,(sprp+spr_x)

                ; Shift HL into AHL -> AH = HL/32
                add hl,hl
                rla
                add hl,hl
                rla
                add hl,hl
                rla
                ld d,a
                ld a,h
                and $fe
                ld e,h

                ld hl,landscape_data            ; height map
                add hl,de
                ld b,(hl)                       ; get height of ground under lander

                ld a,(sprp+spr_y+1)             ; y position of lander from top of screen
                neg
                add a,191                       ; convert to origin at screen bottom
                sub b                           ; subtract ground height
                
                cp 50
                jr nc,move_down                
                cp 20
                jr c,move_up                    ; less than 28 pixels above ground stop moving down

                ld hl,0                         ; set speed to 0
                jr set_dy

move_down:      ld hl,$00b0
                jr set_dy

move_up:        ld hl,-$00b0

set_dy:         ld (sprp+spr_dy),hl
end_move        mend


; ************* Macro for bomber movement

move_bomber     macro(sprp)

                ; only update direction if on frame 1
                ld a,(sprp+spr_frm)
                or a
                jr nz, end_move

                ld hl,(rand0)
                ld de,(rand1)
                ld a,r
                xor d
                rrc l
                rlc e
                rlc e
                rlc e
                xor h
                ld h,a
                add hl,de
                ld (rand0),de
                ld (rand1),hl
                ld hl,(sprp+spr_y)
                ld de,$70
                rra
                ld a,h

                jr c,mov_d      ; move up or down
                cp -2
                jr z,upd_y
                sbc hl,de
                jr upd_y
mov_d           cp 2
                jr z,upd_y
                add hl,de

upd_y           ld (sprp+spr_y),hl
end_move        mend

move_swarmer    macro(sprp)

                ; only update direction if on frame 1
                ld a,(sprp+spr_frm)
                or a
                jr nz,end_move

                ld hl,(sprship+spr_x)
                ld de,(sprp+spr_x)
                ld bc,$40
                xor a
                sbc hl,de
                jr nc,pos_xofs
                ld bc,-$40
                ex de,hl
                xor a
                ld h,a
                ld l,a
                sbc hl,de               ; make HL positive
pos_xofs:
                ld de,$280
                add hl,de
                ld a,h
                cp 5
                jr c,move_y
                ld (sprp+spr_dx),bc

move_y:                
                ld hl,(sprship+spr_y)
                ld de,(sprp+spr_y)
                ld bc,$100
                xor a
                sbc hl,de
                jr nc,pos_yofs
                ld bc,-$100
                xor a
                ld h,a
                ld l,a
                sbc hl,de               ; make HL positive
pos_yofs:                
                ld de,$0a00
                add hl,de
                ld a,h
                cp $14
                jr c,end_move
                ld (sprp+spr_dy),bc
end_move        mend
