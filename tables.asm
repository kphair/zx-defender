
shots_table     db 0,0,0,0,0
                db 0,0,0,0,0
                db 0,0,0,0,0
                db 0,0,0,0,0


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

align 16
firefade:       dg ---#---###-#-###----#--#-#---#-##-#-#------##--#-##----#-##--#-#

align 512
scanlinetable:	dw $4000, $4100, $4200, $4300, $4400, $4500, $4600, $4700
		dw $4020, $4120, $4220, $4320, $4420, $4520, $4620, $4720
		dw $4040, $4140, $4240, $4340, $4440, $4540, $4640, $4740
		dw $4060, $4160, $4260, $4360, $4460, $4560, $4660, $4760
		dw $4080, $4180, $4280, $4380, $4480, $4580, $4680, $4780
		dw $40a0, $41a0, $42a0, $43a0, $44a0, $45a0, $46a0, $47a0
		dw $40c0, $41c0, $42c0, $43c0, $44c0, $45c0, $46c0, $47c0
		dw $40e0, $41e0, $42e0, $43e0, $44e0, $45e0, $46e0, $47e0
		dw $4800, $4900, $4a00, $4b00, $4c00, $4d00, $4e00, $4f00
		dw $4820, $4920, $4a20, $4b20, $4c20, $4d20, $4e20, $4f20
		dw $4840, $4940, $4a40, $4b40, $4c40, $4d40, $4e40, $4f40
		dw $4860, $4960, $4a60, $4b60, $4c60, $4d60, $4e60, $4f60
		dw $4880, $4980, $4a80, $4b80, $4c80, $4d80, $4e80, $4f80
		dw $48a0, $49a0, $4aa0, $4ba0, $4ca0, $4da0, $4ea0, $4fa0
		dw $48c0, $49c0, $4ac0, $4bc0, $4cc0, $4dc0, $4ec0, $4fc0
		dw $48e0, $49e0, $4ae0, $4be0, $4ce0, $4de0, $4ee0, $4fe0
		dw $5000, $5100, $5200, $5300, $5400, $5500, $5600, $5700
		dw $5020, $5120, $5220, $5320, $5420, $5520, $5620, $5720
		dw $5040, $5140, $5240, $5340, $5440, $5540, $5640, $5740
		dw $5060, $5160, $5260, $5360, $5460, $5560, $5660, $5760
		dw $5080, $5180, $5280, $5380, $5480, $5580, $5680, $5780
		dw $50a0, $51a0, $52a0, $53a0, $54a0, $55a0, $56a0, $57a0
		dw $50c0, $51c0, $52c0, $53c0, $54c0, $55c0, $56c0, $57c0
		dw $50e0, $51e0, $52e0, $53e0, $54e0, $55e0, $56e0, $57e0

		dw $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00
		dw $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00
		dw $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00
		dw $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00
		dw $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00
		dw $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00
		dw $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00
		dw $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00, $5b00


attrlinetable:	dw $5800
		dw $5820
		dw $5840
		dw $5860
		dw $5880
		dw $58a0
		dw $58c0
		dw $58e0

		dw $5900
		dw $5920
		dw $5940
		dw $5960
		dw $5980
		dw $59a0
		dw $59c0
		dw $59e0

		dw $5a00
		dw $5a20
		dw $5a40
		dw $5a60
		dw $5a80
		dw $5aa0
		dw $5ac0
		dw $5ae0

                align 256
noise:          db $1B,$9B,$3F,$08,$7F,$51,$55,$9F,$E8,$10,$CB,$89,$4A,$08,$4A,$04
                db $4B,$B4,$3A,$82,$31,$A3,$56,$A5,$5C,$4C,$D6,$53,$37,$D5,$1E,$BF
                db $97,$D1,$EB,$DC,$9D,$7A,$FE,$9A,$87,$67,$CB,$8F,$D1,$99,$C9,$BF
                db $A1,$F5,$A7,$19,$3F,$F9,$94,$C8,$BD,$2F,$D9,$A6,$CD,$C8,$F0,$C0
                db $91,$FA,$30,$7D,$6B,$D7,$CE,$22,$58,$F4,$B7,$C0,$C0,$17,$73,$3B
                db $6A,$35,$02,$71,$28,$6D,$14,$73,$3B,$71,$A1,$6F,$87,$13,$31,$62
                db $C3,$90,$B3,$10,$EE,$E0,$F6,$32,$9E,$AC,$4E,$80,$54,$17,$0B,$07
                db $6F,$20,$89,$CF,$44,$C9,$6C,$CD,$72,$40,$97,$26,$D3,$08,$15,$79
                db $76,$C1,$D2,$F4,$E9,$47,$C9,$51,$14,$20,$0A,$26,$B3,$BC,$77,$07
                db $DE,$ED,$44,$93,$75,$CE,$C0,$09,$19,$59,$C8,$0F,$BE,$C6,$30,$06
                db $C3,$38,$3F,$96,$A7,$C3,$05,$7F,$AA,$65,$6E,$D5,$BD,$75,$29,$50
                db $FD,$C8,$33,$AA,$4F,$38,$79,$BA,$6A,$57,$E0,$16,$8E,$6A,$B1,$34
                db $DA,$A7,$C2,$E2,$22,$36,$AF,$C1,$D2,$B4,$DE,$88,$D3,$E1,$57,$4D
                db $B4,$6B,$E1,$C6,$80,$1F,$38,$68,$D6,$82,$9A,$00,$20,$C0,$0B,$8A
                db $D7,$CF,$76,$F7,$3A,$CC,$AC,$2A,$8C,$8C,$17,$9D,$30,$B5,$BB,$2F
                db $1E,$27,$56,$71,$5C,$6C,$6F,$AD,$5C,$1E,$04,$C7,$75,$EB,$E5,$CD

particledata:   
                ; particles with duplicate lines
                dg --------     ; --  0
                dg --------     ; --
                dg -#-#-#-#     ; -#  5
                dg -#-#-#-#     ; -#
                dg #-#-#-#-     ; #-  A
                dg #-#-#-#-     ; #-
                dg ########     ; ##  F
                dg ########     ; ##

                ; empty bottom lines
                dg ########     ; ##  3
                dg --------     ; --
                dg -#-#-#-#     ; -#  1
                dg --------     ; --
                dg #-#-#-#-     ; #-  2
                dg --------     ; --

                ; empty top lines                
                dg --------     ; --  4
                dg -#-#-#-#     ; -#
                dg --------     ; --  8
                dg #-#-#-#-     ; #-
                dg --------     ; --  C
                dg ########     ; ##

                ; different lines
                dg #-#-#-#-     ; #-  6
                dg -#-#-#-#     ; -#
                dg ########     ; ##  7
                dg -#-#-#-#     ; -#
                dg -#-#-#-#     ; -#  9
                dg #-#-#-#-     ; #-
                dg ########     ; ##  B
                dg #-#-#-#-     ; #-
                dg -#-#-#-#     ; -#  D
                dg ########     ; ##
                dg #-#-#-#-     ; #-  E
                dg ########     ; ##

align 8
particlemask:   dg ##------     ; pixel offset ANDed with %00000110
                dg ##------
                dg --##----
                dg --##----
                dg ----##--
                dg ----##--
                dg ------##
                dg ------##
