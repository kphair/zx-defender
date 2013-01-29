clear_screen	proc

                ld hl, $5800
                ld de, hl
                inc de
                ld bc,$300
                ld (hl),b
                ldir
        
		ld hl,$4660
		ld b,32
		ld a,$ff
l0:		ld (hl),a
		inc h
		ld (hl),a
		inc l
		dec h
		djnz l0

		ld hl,$5860
		ld b,32
		ld a,$01
l1:		ld (hl),a
		inc l
		djnz l1

		ld hl,$0707
		ld ($586f),hl

		ld hl,$4008
		ld b,16
		ld a,$ff
l2:		ld (hl),a
		inc l
		djnz l2

		ld hl,$5808
		ld b,16
		ld a,$01
l3:		ld (hl),a
		inc l
		djnz l3

		ld hl,$0707
		ld ($580f),hl

		ld de,scanlinetable

		ld b,30

l4:             ld a,(de)
                inc de
                add a,7
                ld l,a
                ld a,(de)
                inc de
                ld h,a

                ld (hl),$03
                ld a,l
                add a,17
                ld l,a
                ld (hl),$c0
                djnz l4             

		retp

