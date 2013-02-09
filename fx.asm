; Structure for shots table

shot_timer      equ 0
shot_scrH       equ 1
shot_pulse      equ 2
shot_fade       equ 3
shot_wipe       equ 4
                
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
                ld de,5
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
                jr z,fire_slot_r
                ld de,-4*32
fire_slot_r:
                add hl,de               ; add width of sprite plus a few pixels
                ld de,(camera_x)
                sbc hl,de               ; calculate offset of sprite relative to screen
                
                ; Shift HL into AHL -> AH = HL/32
                add hl,hl
                rla
                add hl,hl
                rla
                add hl,hl
                rla
                
                ld e,h                  ; keep X position for later

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
                ld a,(ship_dir)
                or a
                jr z,set_timer_r
                dec (ix+shot_timer)     ; negative timer if ship faces left
                jr set_timer
set_timer_r:    inc (ix+shot_timer)
set_timer:
                ld (ix+shot_scrH),h     ; high byte of screen address
                ld (ix+shot_pulse),l    ; low byte of pulse location
                ld (ix+shot_fade),l     ; low byte of fade location
                ld (ix+shot_wipe),l     ; low byte of wipe location

animate_shots:  ld ix,shots_table
                ld b,4
                ld a,5
                out (254),a
test_shot:      ld a,(ix+shot_timer)
                or a
                jp z,next_shot

                jp m,shot_left

; This section is for a shot that is traveling right
;
; -  -  -- - --- ----->
;
                ld e,a                  ; save copy of timer in E

                ld h,(ix+shot_scrH)
                ld l,(ix+shot_pulse)    ; pulse moves one byte every frame

                ld a,l
                and $1f
                jr z,solid_trail_r        ; if on the last frame, skip the pulse

                cp 1
                jr z,clear_shot_r

                ld (hl),%01011110
                ld a,h
                and $f8
                rra
                rra
                rra
                or $50
                ld h,a
                ld (hl),ATTR_INKWHT + ATTR_BRIGHT

                ld a,e
                cp 1
                jr z,shot_cycle_r       ; If first frame, skip the first solid trail

solid_trail_r:  ld h,(ix+shot_scrH)     ; reload screen address into HL
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
                or ATTR_BRIGHT
                ld (hl),a

fade_trail_r:   ld a,e
                cp 3                    ; Give the solid trail a couple of frames to be seen
                jr c,shot_cycle_r
                and 3
                cp 1
                jr z,wipe_trail_r         ; trail moves three out of every 4 frames
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
                ;or ATTR_BRIGHT
                ld (hl),a

                jr shot_cycle_r

wipe_trail_r:   ld a,e
                cp 4                    ; don't start wiping the trail until the fade has had a chance to show up
                jr c,shot_cycle_r
                ld h,(ix+shot_scrH)     ; wipe moves one byte every 4 frames
                ld l,(ix+shot_wipe)
                ld (hl),0
                inc l
                ld (ix+4),l                
                jr shot_cycle_r

clear_shot_r:   ld h,(ix+shot_scrH)     ; continue wipe to the edge of screen
                ld l,(ix+shot_wipe)
                ld c,0
                ld (ix),c               ; deactivate this shot
wipe_shot_r:    ld (hl),c
                inc l
                ld a,l
                and $1f
                jr nz,wipe_shot_r

                jp next_shot                

shot_cycle_r:   inc (ix+shot_timer)     ; main counter
                inc (ix+shot_pulse)     ; leave this until last otherwise it messes up the solid trail position
                jp next_shot


; This section is for a shot traveling left
;
; <----- --- - --  -  -
;
shot_left:
                neg
                ld e,a                  ; save copy of abs(timer) in E
                
                ld h,(ix+shot_scrH)
                ld l,(ix+shot_pulse)    ; pulse moves one byte every frame

                ld a,l
                and $1f
                cp $1f
                jr z,solid_trail_l        ; if on the last frame, skip the pulse

                cp $1e
                jr z,clear_shot_l

                ld (hl),%01111010
                ld a,h
                and $f8
                rra
                rra
                rra
                or $50
                ld h,a
                ld (hl), ATTR_INKWHT + ATTR_BRIGHT

                ld a,e
                cp 1
                jr z,shot_cycle_l       ; If first frame, skip the first solid trail

solid_trail_l:  ld h,(ix+shot_scrH)     ; reload screen address into HL
                ld l,(ix+shot_pulse)
                inc l                   ; step right to draw the trail behind the pulse
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
                or ATTR_BRIGHT
                ld (hl),a

fade_trail_l:   ld a,e
                cp 3                    ; Give the solid trail a couple of frames to be seen
                jr c,shot_cycle_l
                and 3
                cp 1
                jr z,wipe_trail_l       ; trail moves three out of every 4 frames
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
                dec l
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
                ld (hl),a               ; colour the trail

                jr shot_cycle_l

wipe_trail_l:   ld a,e
                cp 4                    ; don't start wiping the trail until the fade has had a chance to show up
                jr c,shot_cycle_l
                ld h,(ix+shot_scrH)     ; wipe moves one byte every 4 frames
                ld l,(ix+shot_wipe)
                ld (hl),0
                dec l
                ld (ix+shot_wipe),l                
                jr shot_cycle_l

clear_shot_l:   ld h,(ix+shot_scrH)     ; continue wipe to the edge of screen
                ld l,(ix+shot_wipe)
                ld c,0
                ld (ix),c               ; deactivate this shot
wipe_shot_l:    ld (hl),c
                dec l
                ld a,l
                and $1f
                cp $1f
                jr nz,wipe_shot_l

                jr next_shot                

shot_cycle_l:   dec (ix+shot_timer)     ; main counter
                dec (ix+shot_pulse)     ; leave this until last otherwise it messes up the solid trail position
                jr next_shot

; Carry on to next item in table

next_shot:      ld de,5
                add ix,de
                dec b
                jp nz,test_shot
fire_slots_full:                
                xor a
                out (254),a

no_fire:
                retp

