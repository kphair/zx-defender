; unpack the binary landscape data into heights and generate display file diffs for the drawing routine


unpack_landscape proc

                ld hl,landscape_data
                ld de,landscape_bin
                ld iy,landscape_diffs
                exx
                ld de,$56c0     ; screen position of height 9 (point #2047)
                exx

                ld c,9          ; starting height of point #1
                ex af,af'
                ld a,0          ; 256 bytes of data
        
do_byte         ex af,af'
                ld b,8          ; 8 bits per byte
                ld a,(de)

unpack          rla
                jr c,land_up
                dec c
                jr store
land_up         inc c
store           ld (hl),c
                inc hl

                push af
                ld a,191
                sub c
                exx
                ld ixh,scanlinetable/512
                ld ixl,a
                add ix,ix
                ld l,(ix)
                ld h,(ix+1)
                xor a
                sbc hl,de		; Subtract last point's display file location from current
                ld (iy),l		; store the difference
                ld (iy+1),h
                ld e,(ix)               ; make the old one the current one
                ld d,(ix+1)
                inc iy
                inc iy
                exx
                pop af

                djnz unpack

                inc de
                ex af,af'
                dec a
                jr nz,do_byte

		; Make a copy of the first 256 diffs to wrap around
		ld hl,landscape_diffs
		ld d,iyh
		ld e,iyl
		ld bc,512
		ldir

                retp


; Erase the landscape using landscape_lofs/32 as the offset into the landscape data

erase_landscape proc

                ld a,6
                out (254),a

                ld (restore_sp+1),sp

		ld hl,(landscape_lofs)
                srl h
                rr l
                srl h
                rr l
                srl h
                rr l
                srl h
                rr l
                srl h
                rr l

                ld b,h
                ld c,l

                dec hl
                ld a,h
                and $07
                ld h,a

                ld de,landscape_data
		add hl,de
		ld l,(hl)
		ld a,191
		sub l

		ld l,a
		ld h,scanlinetable/512
		add hl,hl
		ld sp,hl
                pop de			; scanline position of first pixel

                ld sp,landscape_diffs
                ld h,b
                ld l,c
		add hl,hl
		add hl,sp
		ld sp,hl

		ex de,hl

                ld b,32                 ; number of columns
                xor a

next_pixel:     
	    	ld (hl),a
                pop de
                add hl,de
                ld (hl),a
                pop de
                add hl,de
                ld (hl),a
                pop de
                add hl,de
                ld (hl),a
                pop de
                add hl,de
                ld (hl),a
                pop de
                add hl,de
                ld (hl),a
                pop de
                add hl,de
                ld (hl),a
                pop de
                add hl,de
                ld (hl),a
                pop de
                add hl,de

                inc l
                djnz next_pixel

restore_sp      ld sp,0
                xor a
                out (254),a
                retp


; Draw the landscape using landscape_ofs as the offset into the landscape date

land_colour:    dw $0303

draw_landscape  proc

                ld a,4
                out (254),a

                ld (restore_sp+1),sp

		ld hl,(landscape_ofs)
		ld (landscape_lofs),hl
                srl h
                rr l
                srl h
                rr l
                srl h
                rr l
                srl h
                rr l
                srl h
                rr l

                ld b,h
                ld c,l

                dec hl
                ld a,h
                and $07
                ld h,a

                ld de,landscape_data
		add hl,de
		ld l,(hl)
		ld a,191
		sub l

		ld l,a
		ld h,scanlinetable/512
		add hl,hl
		ld sp,hl
                pop de

                ld h,b
                ld l,c

		jr no_colour
                ld sp,$5b00
                ld a,(land_colour)
;                xor $05
                ld b,a
                ld c,a
;                ld (land_colour),bc

                
                ld a,9
colour_land:    push bc:push bc:push bc:push bc:push bc:push bc:push bc:push bc
                push bc:push bc:push bc:push bc:push bc:push bc:push bc:push bc
                dec a
                jr nz colour_land                
		
no_colour:

                ld sp,landscape_diffs
		add hl,hl
		add hl,sp
		ld sp,hl

		ex de,hl

                ld c,$80                ; pixel mask
                ld b,32                 ; number of columns

next_pixel:     
    		ld (hl),c
                pop de
                add hl,de
                rrc c
                ld (hl),c
                pop de
                add hl,de
                rrc c
                ld a,c
                or (hl)
                ld (hl),a
                pop de
                add hl,de
                rrc c
                ld a,c
                or (hl)
                ld (hl),a
                pop de
                add hl,de
                rrc c
                ld a,c
                or (hl)
                ld (hl),a
                pop de
                add hl,de
                rrc c
                ld a,c
                or (hl)
                ld (hl),a
                pop de
                add hl,de
                rrc c
                ld a,c
                or (hl)
                ld (hl),a
                pop de
                add hl,de
                rrc c
                ld a,c
                or (hl)
                ld (hl),a
                pop de
                add hl,de
                rrc c

                inc l
                djnz next_pixel

restore_sp      ld sp,0
                xor a
                out (254),a
                retp


; ************* Update twinkling starfield (x positions are a quarter of screen offset)
                
showstars       proc

                ld a,3
                out (254),a

                ld (restoresp+1),sp
                ld sp,starfield_data
do_star:
                pop hl                  ; retrieve last screen address
                ld a,h
                or a
                jp m,restoresp          ; bit 7 set if table end
                jr nz,erase_star
                
                pop af
                pop af
                pop af
                jr init_star
erase_star:
                pop af                  ; retrieve pixel mask
                and (hl)
                ld (hl),a               ; erase pixel

                pop hl                  ; retrieve star X
                ld b,h
                ld l,e                  ; save copy in BC
                ld de,(landscape_ofs)
                sbc hl,de               ; subtract current landscape offset

                pop de                  ; retrieve timer and y position
                ld a,e
                or a                    ; if timer is zero then generate new star position
                jr nz,animate_star

init_star:
                exx
                ld hl,(rand0)
                ld de,(rand1)
                ld  a,e         ; w = w ^ ( w << 3 )
                add a,a
                add a,a
                add a,a
                xor e
                ld  e,a
                ld  a,h         ; t = x ^ (x << 1)
                add a,a
                xor h
                ld  d,a
                rra             ; t = t ^ (t >> 1) ^ w
                xor d
                xor e
                ld  h,l         ; y = z
                ld  l,a         ; w = t
                ld (rand0),de
                ld (rand1),hl
                exx

                ld bc,(rand0)           ; get new star position
                ld a,b
                and $3f
                rla
                or $40                  ; generate a semi-random timer value between $40 and $7f
                ld e,a
                
                ld a,(rand1)
                ld l,a
                and $7f
                add a,$20                 ; generate a semi-random y value between $20 and $9f
                ld d,a                

animate_star:
                dec e
                push de                 ; E = timer, D = y position
                push bc                 ; save X position back through stack

                ; get HL/128 % 256
                add hl,hl
                ld a,h
                and 7                   ; pixel offset within column
                
                ld b,HIGH pixel_masks   ; convert pixel offset to pixel mask
                or LOW pixel_masks
                ld c,a
                ld a,(bc)
                ld b,a                  ; save mask in B
                push af                 ; store pixel mask for erasure on next frame

                ld a,h
                srl a
                srl a
                srl a
                ld c,a                  ; column offset = X position/8
                
                ld h,(HIGH scanlinetable)/2
                ld l,d                  ; get y position in D
                add hl,hl
                ld a,(hl)               ; look up screen address for y position
                inc l
                ld h,(hl)
                or c                    ; merge column offset for new screen address
                ld l,a

                ld a,b                  ; retrieve pixel mask
                cpl                     ; invert it to generate actual pixel
                or (hl)                 ; merge with screen byte
                ld (hl),a               ; and put back to screen
                push hl                 ; save screen address for erasure on next frame

                ld a,h                  ; convert screen to attr position
                rra
                rra
                rra
                and 7
                or $58
                ld h,a                  
                
                ld a,e                  ; retrieve timer saved in E
                srl a
                srl a
                srl a
                srl a                   ; divide by 16 to create colour
                jr nz,stillvisible      ; check to make sure colour isn't black
                ld a,3
stillvisible:
                ld (hl),a

                ld hl,8
                add hl,sp
                ld sp,hl

                jp do_star
end_stars:
restoresp:      ld sp,0
                                
                xor a
                out (254),a
                      
                retp


align 2

landscape_ofs:	dw 0		; Current offset
landscape_lofs:	dw 0		; Last offset (for erase run)

thrust:         db 0,0,0

landscape_diffs: ds (2048+256)*2

landscape_bin:  db $2A,$AA,$AA,$AA,$AA,$AA,$AB,$A1,$D5,$55,$55,$55,$55,$55,$AA,$BF
                db $FF,$FF,$FF,$C0,$00,$00,$00,$55,$55,$57,$FF,$C0,$01,$55,$55,$55
                db $55,$55,$55,$5F,$E0,$15,$55,$55,$57,$FF,$F0,$00,$15,$55,$5F,$FF
                db $FF,$FF,$FF,$00,$00,$00,$00,$05,$55,$7F,$FF,$E0,$00,$05,$55,$55
                db $55,$55,$FC,$05,$55,$55,$50,$01,$FF,$FF,$FF,$C0,$00,$0A,$AA,$AA
                db $AA,$FF,$00,$00,$FF,$FF,$FF,$FF,$F0,$00,$00,$1F,$E0,$00,$55,$55
                db $55,$40,$AA,$AA,$AA,$AA,$AA,$AA,$B5,$57,$AA,$AA,$AA,$F5,$7F,$D5
                db $55,$55,$57,$FF,$80,$07,$E0,$7F,$F1,$55,$7F,$FF,$FF,$00,$00,$00
                db $00,$00,$0F,$EF,$76,$91,$11,$11,$5E,$DB,$E9,$84,$77,$EC,$C4,$87
                db $47,$98,$08,$98,$3F,$C3,$CB,$DB,$9F,$C7,$5F,$2F,$C7,$7D,$EF,$BF
                db $FA,$4C,$57,$2B,$61,$EF,$EF,$FB,$F7,$E8,$00,$20,$40,$00,$14,$04
                db $04,$3C,$06,$00,$1D,$07,$3C,$E1,$A5,$55,$55,$45,$2A,$AA,$AA,$AA
                db $A8,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$56,$AA,$AA,$FE,$AA
                db $AA,$AA,$AA,$AA,$AA,$AA,$AA,$EA,$AA,$AA,$A8,$02,$AA,$AA,$AA,$AA
                db $BF,$BE,$3E,$63,$FF,$E0,$D8,$1C,$18,$2A,$AB,$1E,$77,$7A,$AF,$A8
                db $40,$70,$7D,$40,$0B,$FB,$FA,$FF,$C1,$53,$54,$75,$70,$03,$00,$00

landscape_data: ds 2048

; Starfield data
; WORD screen address
; WORD pixel mask (AF)
; WORD x position
; BYTE timer
; BYTE y position

starfield_data: dw 0,0,0,0
                dw 0,0,0,0
                dw 0,0,0,0
                dw 0,0,0,0
                dw 0,0,0,0
                dw 0,0,0,0
                dw 0,0,0,0
                dw 0,0,0,0
                dw 0,0,0,0
                dw 0,0,0,0
                dw 0,0,0,0
                dw $ffff,$ffff,$ffff,$ffff
                
                align 16
pixel_masks:    db %01111111
                db %10111111
                db %11011111
                db %11101111
                db %11110111
                db %11111011
                db %11111101
                db %11111110
pixel_bits:     db %10000000
                db %01000000
                db %00100000
                db %00010000
                db %00001000
                db %00000100
                db %00000010
                db %00000001
