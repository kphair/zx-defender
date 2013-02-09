; Structure for shots table

shot_timer      equ 0
shot_scrH       equ 1
shot_pulse      equ 2
shot_fade       equ 3
shot_wipe       equ 4
shot_dir        equ 5                    ; -1 for left, 1 for right


; ************* Test for fire button

test_fire       proc

                ld a,(controls)
                and ctrl_fire
                jr nz,animate_shots     ; if fire not pressed just animate any existing shots
                ld a,(lastcontrols)
                and ctrl_fire
                jr z,animate_shots      ; only fire new shots if the control is not already pressed

                ld a,5
                out (254),a

                ld hl,shots_table       ; search for a free slot from the 4 available
                ld de,6                 ; size of table entry
                ld b,4

find_fire_slot: ld a,(hl)
                or a
                jr z,fire_slot          ; found a free slot
                add hl,de
                djnz find_fire_slot     ; loop around to check next slot
                jp fire_slots_full


fire_slot:
                ; Get screen address of space in front of ship

                push hl                 ; save HL
                ld hl,(sprship+spr_x)
                ld de,20*32
                ld a,(ship_dir)
                or a
                ld a,1
                jr z,fire_slot_r
                ld de,-4*32
                ld a,-1
fire_slot_r:
                add hl,de               ; add width of sprite plus a few pixels
                ld de,(camera_x)
                sbc hl,de               ; calculate offset of sprite relative to screen

                ; Shift HL << 3; H = HL/32
                add hl,hl
                add hl,hl
                add hl,hl
                ld e,h                  ; keep X position for later
                ld d,a                  ; save shot direction in D

                ; Get screen address of vertical position of new shot

                ld a,(sprship+spr_y+1)
                add a,4                 ; line it up with the nose of the ship
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
                ld (ix+shot_dir),d

; go through the shot table, checking the timer values to find active shots

animate_shots:  ld ix,shots_table
                ld iyl,4
                ld a,5
                out (254),a
test_shot:      ld a,(ix+shot_timer)
                or a
                jp z,next_shot

; Perform the actual drawing of the shot

                ld e,a                  ; save copy of timer in E
                ld d,(ix+shot_dir)      ; save shot direction in D

                ld h,(ix+shot_scrH)
                ld l,(ix+shot_pulse)    ; pulse moves one byte every frame

                ld a,d                  ; get shot direction
                dec a                   ; set Z if going right
                ld a,l                  ; get column position
                jr nz,wrap_l
                ; check for wrap around to left of screen if going right
                and $1f
                jr z,solid_trail        ; pulse has wrapped around so don't draw it
                cp 1
                jp z,clear_shot         ; pulse & trail have wrapped around so deactivate shot
                ld a,%11111000
                jr draw_pulse
                ; check for wrap around to right of screen if going left
        wrap_l  and $1f
                cp $1f
                jr z,solid_trail        ; if on the last frame, skip the pulse
                cp $1e
                jp z,clear_shot
                ld a,%00011111
                ;jr draw_pulse

draw_pulse:     ld (hl),a
                ld a,h
                and $f8
                rra
                rra
                rra
                or $50
                ld h,a
                ld (hl),ATTR_INKWHT + ATTR_BRIGHT

                ld a,e
                cp 1                    ; don't draw the solid trail on frame 1
                jp z,shot_cycle         ; otherwise it will draw over the ship

                ld h,(ix+shot_scrH)     ; reload screen address into HL
                ld l,(ix+shot_pulse)

solid_trail:    ld a,d
                neg                     ; change sign of direction to move behind pulse
                add a,l
                ld l,a
                ld (hl),$ff

                ld a,h                  ; colour in the solid trail
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
                or ATTR_BRIGHT
                ld (hl),a

fade_trail:     ld a,e
                cp 3                    ; don't start processing fade until frame 3
                jr c,shot_cycle
                and 3
                cp 1
                jr z,wipe_trail
                ld h,(ix+shot_scrH)
                ld l,(ix+shot_fade)
                ld b,HIGH firefade
                ld a,r
                add a,l
                and 7
                add a,LOW firefade
                ld c,a
                ld a,(bc)
                ld (hl),a
                ld a,d                  ; add shot direction
                add a,l
                ld l,a
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
                ld (hl),a

                jr shot_cycle

wipe_trail:     ld a,e
                cp 4                    ; only start processing the wipe from frame 4 on
                jr c,shot_cycle
                ld h,(ix+shot_scrH)
                ld l,(ix+shot_wipe)
                ld (hl),0
                ld a,d                  ; add shot direction
                add a,l
                ld l,a
                ld (ix+4),l
                jr shot_cycle

clear_shot:     ld h,(ix+shot_scrH)     ; continue wipe to the edge of screen
                ld l,(ix+shot_wipe)
                ld c,0
                ld (ix),c               ; deactivate this shot
wipe_shot:      ld (hl),c
                ld a,d                  ; add shot direction
                add a,l
                ld l,a
                and $1f
                jr nz,wipe_shot
                ld a,d                  ; if shooting left do one more to clear column 0
                dec a
                jr z,next_shot
                ld (hl),c

                jr next_shot

shot_cycle:     inc (ix+shot_timer)     ; main counter
                ld a,d
                add a,(ix+shot_pulse)
                ld (ix+shot_pulse),a    ; leave this until last otherwise it messes up the solid trail position
                jp next_shot

; Carry on to next item in table

next_shot:      ld de,6
                add ix,de
                dec iyl
                jp nz,test_shot
fire_slots_full:
                xor a
                out (254),a

no_fire:
                retp

