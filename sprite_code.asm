
; Place a sprite on the screen
; IY = address of sprite parameters

place_2bsprite  proc

                ld a,2
                out (254),a

                ld (restoresp+1),sp
                
                ld sp,iy                ; point stack at sprite parameter list
                pop de                  ; retrieve screen address for erasure
                pop hl                  ; retrieve sprite data source
                pop bc                  ; retrieve column and height
                ld a,d
                or a
                jr z,no_erase

                ld (erase_sp+1),sp
                ld sp,hl
                ex de,hl
erase:
                pop de

                ld a,e
                cpl                     ; invert A to create mask
                and (hl)
                ld (hl),a
                inc l

                ld a,d
                cpl
                and (hl)
                ld (hl),a
                dec l

                ; increment pixel line code from Cobra, thanks Joffa!
                inc h                           
                ld a,h
                and $07
                jr nz,nxteraseline
                ld a,l
                add a,$20
                ld l,a
                jr c,nxteraseline
                ld a,h
                sub $08
                ld h,a
nxteraseline:
                djnz erase
                ld (iy+spr_dst+1),b     ; clear high byte of screen address to denote erase done

erase_sp:       ld sp,0

no_erase:
                ld a,1
                out (254),a

                pop ix                  ; retrieve address of sprite descriptor table
                pop hl                  ; retrieve X position

                ld de,(landscape_ofs)
                xor a
                sbc hl,de               ; calculate offset of sprite relative to screen

                ; Shift HL into AHL -> AH = HL/32
                add hl,hl
                rla
                add hl,hl
                rla
                add hl,hl
                rla
                and a
                jp nz,restoresp
                ld a,h
                cp 248
                jp nc,restoresp

                ld b,a                  ; calculate preshift offset
                and 7
                add a,a
                add a,LOW preshift0
                ld l,a
                ld h,HIGH preshift0     ; HL = offset into preshift bank address lookup table
                ld a,(hl)
                inc l
                ld h,(hl)
                ld l,a                  ; HL = start of preshifted sprite bank for pixel position

                pop af                  ; retrieve current frame number
                
                add a,a                 ; look up frame address offset in sprite descriptor table (IX)
                add a,sprd_frame0
                add a,ixl
                ld (frmixop+2),a
                ld a,0
                adc a,ixh
                ld (frmixop+3),a

frmixop:        ld de,(0)               ; ED 5B xx xx
                add hl,de               ; HL = address of preshifted sprite frame
                ld (iy+spr_src),l
                ld (iy+spr_src+1),h     ; Save for erase

                pop de                  ; get y position

                ld sp,hl                ; all parameters retrieve, now point stack to sprite data

                ex de,hl                ; move y position into HL
                ld l,h                  ; and convert to screen address
                ld h,(HIGH scanlinetable)/2
                add hl,hl
                ld a,(hl)
                inc l
                ld h,(hl)
                ld l,a

                ld a,b                 ; get x position again, divide by 8 to get column
                srl a
                srl a
                srl a
                ld c,a                 ; C = pixel column (0 - 255) converted to byte column (0 - 31)
                ld (iy+spr_col),c      ; save for erase

                ld a,7
                out (254),a

                ld a,l
                or c
                ld l,a          ; merge column (0 - 31) offset

                ld (iy+spr_dst),l
                ld (iy+spr_dst+1),h     ; save for erase

                ld a,h                  ; convert screen address to attr address
                srl a
                srl a
                srl a
                or $50
                ld h,a
                ld a,(ix+sprd_attr)
                ld (hl),a
                inc l
                ld (hl),a

                ld b,(ix+sprd_height)
                ld (iy+spr_h),b

                ld l,(iy+spr_dst)       ; Get screen address back into HL
                ld h,(iy+spr_dst+1) 
printline:
                pop de                  ; get two bytes of sprite data

                ld a,e
                or (hl)
                ld (hl),a
                inc l

                ld a,d
                or (hl)
                ld (hl),a
                dec l

                inc h
                ld a,h
                and $07
                jr nz,nxtprintline
                ld a,l
                add a,$20
                ld l,a
                jr c,nxtprintline
                ld a,h
                sub $08
                ld h,a
nxtprintline:
                djnz printline

; Do attribute blocks

                ld a,h
                srl a
                srl a
                srl a
                or $50
                ld h,a
                ld a,(ix+1)
                ld (hl),a
                inc l
                ld (hl),a

restoresp:      ld sp,0

                ld a,0
                out (254),a

                retp


place_3bsprite  proc

                ld a,2
                out (254),a

                ld (restoresp+1),sp

                ld sp,iy                ; point stack at sprite parameter list
                pop hl                  ; retrieve position in scan line table
                ld a,h
                or a

                pop de                  ; retrieve sprite data source
                pop bc                  ; retrieve column and height
                jr z,no_erase

                ld (restoresp0+1),sp
                ld sp,hl                ; now point to the scan line table
erase:
                pop hl                  ; retrieve scan line position in display file
                ld a,l
                or c                    ; add column offset
                ld l,a

                ld a,(de)
                cpl                     ; invert A to create mask
                and (hl)
                ld (hl),a
                inc l
                inc de 

                ld a,(de)
                cpl                     ; invert A to create mask
                and (hl)
                ld (hl),a
                inc l
                inc de 

                ld a,(de)
                cpl
                and (hl)
                ld (hl),a
                inc de

                djnz erase

                ld (iy+spr_dst+1),b

restoresp0:     ld sp,0                 ; restore stack to sprite parameter block

no_erase:
                ld a,1
                out (254),a

                pop ix                  ; retrieve address of sprite descriptor table

                pop hl                  ; retrieve X position
                ld de,(landscape_ofs)
                xor a
                sbc hl,de               ; calculate offset of sprite relative to screen

                ; Shift HL into AHL -> AH = HL/32
                add hl,hl
                rla
                add hl,hl
                rla
                add hl,hl
                rla
                and a
                jp nz,restoresp
                ld a,h
                cp 240
                jp nc,restoresp

                ld b,a                  ; calculate preshift offset
                and 7
                add a,a
                add a,LOW preshift0
                ld l,a
                ld h,HIGH preshift0     ; HL = offset into preshift bank address lookup table
                ld a,(hl)
                inc l
                ld h,(hl)
                ld l,a                  ; HL = start of preshifted sprite bank for pixel position

                pop af                  ; retrieve current frame number
                
                add a,a                 ; look up frame address offset in sprite descriptor table (IX)
                add a,sprd_frame0
                add a,ixl
                ld (frmixop+2),a
                ld a,0
                adc a,ixh
                ld (frmixop+3),a

frmixop:        ld de,(0)               ; ED 5B xx xx
                add hl,de               ; HL = address of preshifted sprite frame
                ld (iy+spr_src),l
                ld (iy+spr_src+1),h     ; Save for erase

                ex de,hl                ; protect HL
                pop hl                  ; get y position
                ld l,h
                ld h,scanlinetable/512
                add hl,hl
                ld sp,hl                ; first lookup position in scan line table for y position
                ld (iy+spr_dst),l
                ld (iy+spr_dst+1),h     ; save for erase
                ex de,hl                ; recover HL

                ld a,b                 ; get x position again, divide by 8 to get column
                srl a
                srl a
                srl a
                ld c,a                 ; C = pixel column (0 - 255) converted to byte column (0 - 31)
                ld (iy+spr_col),c      ; save for erase

                ld a,7
                out (254),a

                pop de          ; get top scanline for first line of attributes
                dec sp
                dec sp

                ld a,e
                or c
                ld e,a          ; merge column (0 - 31) offset

                ld a,d
                srl a
                srl a
                srl a
                or $50
                ld d,a
                ld a,(ix+sprd_attr)
                ld (de),a
                inc e
                ld (de),a
                inc e
                ld (de),a

                ld b,(ix+sprd_height)
                ld (iy+spr_h),b
printline:
                pop de          ; get address of scanline
                ld a,e
                or c
                ld e,a          ; merge column (0 - 31) offset

                ld a,(de)       ; get 1 byte of sprite data and XOR to screen
                or (hl)
                ld (de),a
                inc hl
                inc e

                ld a,(de)       ; do another byte
                or (hl)
                ld (de),a
                inc hl
                inc e

                ld a,(de)       ; do another byte
                or (hl)
                ld (de),a
                inc hl

                djnz printline

; Do attribute blocks

                ld a,d
                srl a
                srl a
                srl a
                or $50
                ld d,a
                ld a,(ix+1)
                ld (de),a
                dec e
                ld (de),a
                dec e
                ld (de),a

restoresp:      ld sp,0

                ld a,0
                out (254),a

                retp



; Preshift bank offsets
align 16
preshift0:      dw spritedatastart+(preshiftdata-spritedatastart)*0
preshift1:      dw spritedatastart+(preshiftdata-spritedatastart)*1
preshift2:      dw spritedatastart+(preshiftdata-spritedatastart)*2
preshift3:      dw spritedatastart+(preshiftdata-spritedatastart)*3
preshift4:      dw spritedatastart+(preshiftdata-spritedatastart)*4
preshift5:      dw spritedatastart+(preshiftdata-spritedatastart)*5
preshift6:      dw spritedatastart+(preshiftdata-spritedatastart)*6
preshift7:      dw spritedatastart+(preshiftdata-spritedatastart)*7


; Read the sprite list and create preshifted versions of all the sprites
; A table will be generated with the start address of each preshifted bank

preshift_sprites proc

                ld hl,spritedatastart
                ld de,preshiftdata
                ld bc,(preshiftdata-spritedatastart)*7
		inc b

shift1byte      ex af,af'
                ld a,(hl)
                rra
                ld (de),a
                ex af,af'

                inc hl
                inc de

                dec c
                jr nz, shift1byte
                djnz shift1byte

                retp


                