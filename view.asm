; ************* Set the camera position

; Calculate new landscape offset from ship_x:
; add thrust to ship_x
; add thrust to camera_x
; subtract desired screen edge offset (40 or 200) from ship_x and compare to camera_x
; if <0 then pan left
; if >0 then pan right
; if within range then set the camera position to be exactly ship_x - 40 * 32 - thrust * 8 if ship facing right
; or ship_x - 200 * 32 + thrust * 8 if facing left

set_camera      proc                

                ld de,(thrust+1)

                ld hl,(sprship+spr_x)
                add hl,de
		ld (sprship+spr_x),hl

                ld hl,(camera_x)
                ld (camera_lastx),hl
                add hl,de
                ld (camera_x),hl

                ex de,hl
                ld hl,(sprship+spr_x)   ; subtract camera_x from ship_x
                or a
                sbc hl,de
                
                ld a,(ship_dir)
                or a
                jr z,chk_pan_right

; ship is facing left, do we need to pan left to bring to the right side of screen

chk_pan_left:   ld bc,200*32            ; subtract the desired ship offset (200*32 - thrust*8) from screen edge
                ex de,hl
                ld hl,(thrust+1)
                add hl,hl
                add hl,hl
                add hl,hl
                ex de,hl
                add hl,de
                sbc hl,bc
                jp p,no_pan_left
                ld de,-3*32
                jr do_pan

; if the ship is 200 pixels or more to the right of the camera position then 
no_pan_left:    ld hl,(thrust+1)        ; calculate thrust * 8
                add hl,hl
                add hl,hl
                add hl,hl
                ex de,hl
                ld hl,(sprship+spr_x)   ; subtract 200*32 from ship_x
                or a
                sbc hl,bc
                add hl,de               ; add thrust to offset ship from right edge of screen with increasing thrust
                jr fix_camera_x

; if the ship is facing right, do we need to pan right to bring it to the left side of screen

chk_pan_right:  ld bc,40*32             ; subtract the desired ship offset from screen edge
                ex de,hl
                ld hl,(thrust+1)
                add hl,hl
                add hl,hl
                add hl,hl
                ex de,hl
                sbc hl,bc
                sbc hl,de
                jp m,no_pan_right       ; don't pan if result negative
                jr z,no_pan_right       ; or zero
                ld de,3*32
                jr do_pan

no_pan_right:   ld hl,(thrust+1)        ; calculate thrust * 8
                add hl,hl
                add hl,hl
                add hl,hl
                ex de,hl
                ld hl,(sprship+spr_x)   ; subtract 40*32 from ship_x
                or a
                sbc hl,bc
                sbc hl,de               ; subtract thrust to offset ship from left edge of screen with increasing thrust
                jr fix_camera_x

do_pan:         ld hl,(camera_x)
                add hl,de                
fix_camera_x:
                ld (camera_x),hl

                retp

        