; Sprite parameter records
;
spr_dst         equ 0   ; dw scanline list first line position
spr_src         equ 2   ; dw sprite data source
spr_col         equ 4   ; db column position
spr_h           equ 5   ; db bit 0-5 = number of lines high, bit 7-8 = bytes wide
spr_dsc         equ 6   ; dw address of sprite descriptor
spr_x           equ 8   ; dw x position
spr_pad         equ 10  ; db unused
spr_frm         equ 11  ; db frame number
spr_y           equ 12  ; dw x position
spr_dx          equ 14  ; x delta
spr_dy          equ 16  ; y delta

spr0:           dw 0,0,0
                dw spr_lander
                dw $2000
                db 0,0
                dw $3000
                dw $10,$40
spr1:           dw 0,0,0
                dw spr_lander
                dw $4000
                db 0,0 
                dw $3000
                dw $7,$30
spr2:           dw 0,0,0
                dw spr_lander
                dw $6000
                db 0,0
                dw $4000
                dw $11,$20
spr3:           dw 0,0,0
                dw spr_lander
                dw $8000
                db 0,0
                dw $5000
                dw -$10,$20
spr4:           dw 0,0,0
                dw spr_lander
                dw $5000
                db 0,0
                dw $6000
                dw -$8,$10
spr5:           dw 0,0,0
                dw spr_bomber
                dw $a000
                db 0,0
                dw $3000
                dw -$10,0
spr6:           dw 0,0,0
                dw spr_bomber
                dw $9000
                db 0,0
                dw $5000
                dw -$e,0
spr7:           dw 0,0,0
                dw spr_lander
                dw $c600
                db 0,0
                dw $3000
                dw $20,0
spr8:           dw 0,0,0
                dw spr_lander
                dw $c000
                db 0,0
                dw $3000
                dw $30,0
spr9:           dw 0,0,0
                dw spr_baiter
                dw $c600
                db 0,0
                dw $3700
                dw 0,0
spr10:          dw 0,0,0
                dw spr_baiter
                dw $c000
                db 0,0
                dw $3100
                dw 0,0
spr11:          dw 0,0,0
                dw spr_baiter
                dw $c200
                db 0,0
                dw $2800
                dw 0,0
spr12:          dw 0,0,0
                dw spr_pod
                dw $8000
                db 0,0
                dw $8000
                dw -$2,-$40

sprship:        dw 0,0,0
                dw spr_shipr
                dw $2000
                db 0,0
                dw $8000
                dw 0,0

sprexhaust:     dw 0,0,0
                dw spr_idler
                dw $2000
                db 0,0
                dw $8000
                dw 0,0

; Sprite descriptor records
;
sprd_frames     equ 0   ; db frames
sprd_attr       equ 1   ; db attribute
sprd_width      equ 2   ; db width (bytes)
sprd_height     equ 3   ; db height (lines)
sprd_frame0     equ 4   ; db frame 1 address offset in preshift bank

spritelist:

spr_lander:     db 18,$04,2,8
                dw lander0-spritedatastart
                dw lander0-spritedatastart
                dw lander0-spritedatastart
                dw lander0-spritedatastart
                dw lander0-spritedatastart
                dw lander0-spritedatastart
                dw lander1-spritedatastart
                dw lander1-spritedatastart
                dw lander1-spritedatastart
                dw lander1-spritedatastart
                dw lander1-spritedatastart
                dw lander1-spritedatastart
                dw lander2-spritedatastart
                dw lander2-spritedatastart
                dw lander2-spritedatastart
                dw lander2-spritedatastart
                dw lander2-spritedatastart
                dw lander2-spritedatastart
        
spr_mutant:     db 1,$03,2,8
                dw mutant0-spritedatastart

spr_bomber:     db 18,$41,2,8
                dw bombera0-spritedatastart
                dw bombera1-spritedatastart
                dw bombera0-spritedatastart
                dw bombera1-spritedatastart
                dw bombera0-spritedatastart
                dw bombera1-spritedatastart
                dw bombera2-spritedatastart
                dw bombera3-spritedatastart
                dw bombera2-spritedatastart
                dw bombera3-spritedatastart
                dw bombera2-spritedatastart
                dw bombera3-spritedatastart
                dw bombera4-spritedatastart
                dw bombera5-spritedatastart
                dw bombera4-spritedatastart
                dw bombera5-spritedatastart
                dw bombera4-spritedatastart
                dw bombera5-spritedatastart

spr_baiter:     db 18,$04,3,4
                dw baiter0-spritedatastart
                dw baiter0-spritedatastart
                dw baiter0-spritedatastart
                dw baiter0-spritedatastart
                dw baiter0-spritedatastart
                dw baiter0-spritedatastart
                dw baiter1-spritedatastart
                dw baiter1-spritedatastart
                dw baiter1-spritedatastart
                dw baiter1-spritedatastart
                dw baiter1-spritedatastart
                dw baiter1-spritedatastart
                dw baiter2-spritedatastart
                dw baiter2-spritedatastart
                dw baiter2-spritedatastart
                dw baiter2-spritedatastart
                dw baiter2-spritedatastart
                dw baiter2-spritedatastart

spr_swarmer:    db 6,$02,2,4
                dw swarmer0-spritedatastart
                dw swarmer0-spritedatastart
                dw swarmer0-spritedatastart
                dw swarmer0-spritedatastart
                dw swarmer0-spritedatastart
                dw swarmer0-spritedatastart

spr_pod:        db 18,$06,2,7
                dw pod0-spritedatastart
                dw pod0-spritedatastart
                dw pod0-spritedatastart
                dw pod0-spritedatastart
                dw pod0-spritedatastart
                dw pod0-spritedatastart
                dw pod1-spritedatastart
                dw pod1-spritedatastart
                dw pod1-spritedatastart
                dw pod2-spritedatastart
                dw pod2-spritedatastart
                dw pod2-spritedatastart
                dw pod3-spritedatastart
                dw pod3-spritedatastart
                dw pod3-spritedatastart
                dw pod4-spritedatastart
                dw pod4-spritedatastart
                dw pod4-spritedatastart

spr_bomb:       db 20,$05,2,3
                dw bomb0-spritedatastart
                dw bomb0-spritedatastart
                dw bomb0-spritedatastart
                dw bomb0-spritedatastart
                dw bomb0-spritedatastart
                dw bomb0-spritedatastart
                dw bomb0-spritedatastart
                dw bomb0-spritedatastart
                dw bomb0-spritedatastart
                dw bomb0-spritedatastart
                dw bomb1-spritedatastart
                dw bomb1-spritedatastart
                dw bomb1-spritedatastart
                dw bomb1-spritedatastart
                dw bomb1-spritedatastart
                dw bomb1-spritedatastart
                dw bomb1-spritedatastart
                dw bomb1-spritedatastart
                dw bomb1-spritedatastart
                dw bomb1-spritedatastart

spr_humanoidl0: db 1,$07,2,8
                dw humanoidl0-spritedatastart
spr_humanoidl1: db 1,$07,2,8
                dw humanoidl1-spritedatastart
spr_humanoidr0: db 1,$07,2,8
                dw humanoidr0-spritedatastart
spr_humanoidr1: db 1,$07,2,8
                dw humanoidr1-spritedatastart

spr_shipr:      db 15,$07,3,6
                dw shipr0-spritedatastart
                dw shipr0-spritedatastart
                dw shipr0-spritedatastart
                dw shipr0-spritedatastart
                dw shipr0-spritedatastart
                dw shipr1-spritedatastart
                dw shipr1-spritedatastart
                dw shipr1-spritedatastart
                dw shipr1-spritedatastart
                dw shipr1-spritedatastart
                dw shipr2-spritedatastart
                dw shipr2-spritedatastart
                dw shipr2-spritedatastart
                dw shipr2-spritedatastart
                dw shipr2-spritedatastart

spr_shipl:      db 15,$07,3,6
                dw shipl0-spritedatastart
                dw shipl0-spritedatastart
                dw shipl0-spritedatastart
                dw shipl0-spritedatastart
                dw shipl0-spritedatastart
                dw shipl1-spritedatastart
                dw shipl1-spritedatastart
                dw shipl1-spritedatastart
                dw shipl1-spritedatastart
                dw shipl1-spritedatastart
                dw shipl2-spritedatastart
                dw shipl2-spritedatastart
                dw shipl2-spritedatastart
                dw shipl2-spritedatastart
                dw shipl2-spritedatastart


spr_idler:      db 16,$06,2,6
                dw idler0-spritedatastart
                dw idler0-spritedatastart
                dw idler1-spritedatastart
                dw idler0-spritedatastart
                dw idler1-spritedatastart
                dw idler1-spritedatastart
                dw idler2-spritedatastart
                dw idler1-spritedatastart
                dw idler2-spritedatastart
                dw idler2-spritedatastart
                dw idler3-spritedatastart
                dw idler2-spritedatastart
                dw idler3-spritedatastart
                dw idler3-spritedatastart
                dw idler0-spritedatastart
                dw idler3-spritedatastart
                
spr_idlel:      db 16,$06,2,6
                dw idlel0-spritedatastart
                dw idlel0-spritedatastart
                dw idlel1-spritedatastart
                dw idlel0-spritedatastart
                dw idlel1-spritedatastart
                dw idlel1-spritedatastart
                dw idlel2-spritedatastart
                dw idlel1-spritedatastart
                dw idlel2-spritedatastart
                dw idlel2-spritedatastart
                dw idlel3-spritedatastart
                dw idlel2-spritedatastart
                dw idlel3-spritedatastart
                dw idlel3-spritedatastart
                dw idlel0-spritedatastart
                dw idlel3-spritedatastart
                
spr_thrustr:    db 16,$06,2,6
                dw thrustr0-spritedatastart
                dw thrustr1-spritedatastart
                dw thrustr0-spritedatastart
                dw thrustr1-spritedatastart
                dw thrustr1-spritedatastart
                dw thrustr2-spritedatastart
                dw thrustr1-spritedatastart
                dw thrustr2-spritedatastart
                dw thrustr2-spritedatastart
                dw thrustr3-spritedatastart
                dw thrustr2-spritedatastart
                dw thrustr3-spritedatastart
                dw thrustr3-spritedatastart
                dw thrustr0-spritedatastart
                dw thrustr3-spritedatastart
                dw thrustr0-spritedatastart
                
spr_thrustl:    db 16,$06,2,6
                dw thrustl0-spritedatastart
                dw thrustl1-spritedatastart
                dw thrustl0-spritedatastart
                dw thrustl1-spritedatastart
                dw thrustl1-spritedatastart
                dw thrustl2-spritedatastart
                dw thrustl1-spritedatastart
                dw thrustl2-spritedatastart
                dw thrustl2-spritedatastart
                dw thrustl3-spritedatastart
                dw thrustl2-spritedatastart
                dw thrustl3-spritedatastart
                dw thrustl3-spritedatastart
                dw thrustl0-spritedatastart
                dw thrustl3-spritedatastart
                dw thrustl0-spritedatastart
                
                db 0

align 2

spritedatastart:

; Unshifted source data for sprites
;           ______  ______  ______
;          /   0  \/   1  \/   2  \
lander0:        dg ---###----------
                dg --#####---------
                dg -#-##-##--------
                dg -#-##-##--------
                dg --#####---------
                dg --#-#-#---------
                dg -#--#--#--------
                dg #---#---#-------
lander1:
                dg ---###----------
                dg --#####---------
                dg -##-##-#--------
                dg -##-##-#--------
                dg --#####---------
                dg --#-#-#---------
                dg -#--#--#--------
                dg #---#---#-------
lander2:
                dg ----------------
                dg --#####---------
                dg -###-###--------
                dg -###-###--------
                dg --#####---------
                dg --#-#-#---------
                dg -#--#--#--------
                dg #---#---#-------
mutant0:
                dg ---##-----------
                dg --###-#---------
                dg -#-###-#--------
                dg -#-###-#--------
                dg --#####---------
                dg --#-#-#---------
                dg -#--#--#--------
                dg #---#---#-------
bombera0:
                dg -#-#-#----------
                dg --#-#-----------
                dg ######----------
                dg #---#-----------
                dg #---##----------
                dg #---#-----------
                dg #####-----------
                dg ----------------
bombera1:
                dg --#-#-----------
                dg -#-#-#----------
                dg #####-----------
                dg #---##----------
                dg #---#-----------
                dg #---#-----------
                dg #####-----------
                dg ----------------
bombera2:
                dg -#-#-#----------
                dg --#-#-----------
                dg -----#----------
                dg ----------------
                dg --#--#----------
                dg ----------------
                dg ----------------
                dg ----------------
bombera3:
                dg --#-#-----------
                dg -#-#-#----------
                dg ----------------
                dg -----#----------
                dg --#-------------
                dg ----------------
                dg ----------------
                dg ----------------
bombera4:
                dg -#-#-#----------
                dg --#-#-----------
                dg -----#----------
                dg -###------------
                dg -#-#-#----------
                dg -###------------
                dg ----------------
                dg ----------------
bombera5:
                dg --#-#-----------
                dg -#-#-#----------
                dg ----------------
                dg -###-#----------
                dg -#-#------------
                dg -###------------
                dg ----------------
                dg ----------------
swarmer0:
                dg --#-------------
                dg -###------------
                dg #-#-#-----------
                dg -###------------
pod0:
                dg ---#------------
                dg -#-#-#----------
                dg --###-----------
                dg #-#-#-#---------
                dg --###-----------
                dg -#-#-#----------
                dg ---#------------
pod1:
                dg ----------------
                dg ---#------------
                dg --#-#-----------
                dg ##-#-##---------
                dg --#-#-----------
                dg ---#------------
                dg ----------------
pod2:
                dg ----------------
                dg ---#------------
                dg --###-----------
                dg ###-###---------
                dg --###-----------
                dg ---#------------
                dg ----------------
pod3:
                dg ---#------------
                dg ---#------------
                dg --###-----------
                dg -##-##----------
                dg --###-----------
                dg ---#------------
                dg ---#------------
pod4:
                dg ---#------------
                dg ---#------------
                dg --#-#-----------
                dg -#-#-#----------
                dg --#-#-----------
                dg ---#------------
                dg ---#------------
bomb0:
                dg #-#-------------
                dg -#--------------
                dg #-#-------------
bomb1:
                dg -#--------------
                dg ###-------------
                dg -#--------------
humanoidl0:
                dg ##--------------
                dg ##--------------
                dg ###-------------
                dg ###-------------
                dg ###-------------
                dg -#--------------
                dg -#--------------
                dg -#--------------
humanoidl1:
                dg ##--------------
                dg ##--------------
                dg ###-------------
                dg ###-------------
                dg ###-------------
                dg ##--------------
                dg ##--------------
                dg ##--------------
humanoidr0:
                dg -##-------------
                dg -##-------------
                dg ###-------------
                dg ###-------------
                dg ###-------------
                dg -#--------------
                dg -#--------------
                dg -#--------------
humanoidr1:
                dg -##-------------
                dg -##-------------
                dg ###-------------
                dg ###-------------
                dg ###-------------
                dg -##-------------
                dg -##-------------
                dg -##-------------
baiter0:
                dg --#######---------------
                dg -##--#--##--------------
                dg ###-##-##-#-------------
                dg -#########--------------
baiter1:
                dg --#######---------------
                dg -#--#--#-#--------------
                dg #-##-##-###-------------
                dg -#########--------------
baiter2:
                dg --#######---------------
                dg -#-#--#--#--------------
                dg ##-##-##-##-------------
                dg -#########--------------
shipr0:
                dg --##--------------------
                dg -####-------------------
                dg ######------------------
                dg -########--#------------
                dg ###############---------
                dg --######----------------
shipr1:
                dg --##--------------------
                dg -####-------------------
                dg ######------------------
                dg -########-#-------------
                dg ###############---------
                dg --######----------------
shipr2:
                dg --##--------------------
                dg -####-------------------
                dg ######------------------
                dg -#########--------------
                dg ###############---------
                dg --######----------------
idler0:       
                dg ----------------
                dg ------#---------
                dg -------#--------
                dg -------#--------
                dg ------#---------
                dg ------#---------
idler1:       
                dg ----------------
                dg -------#--------
                dg ------##--------
                dg ------#---------
                dg -------#--------
                dg ------#---------
idler2:       
                dg ----------------
                dg ------#---------
                dg ----------------
                dg ------##--------
                dg ------#---------
                dg -------#--------
idler3:       
                dg ----------------
                dg ----------------
                dg ------#---------
                dg ----------------
                dg ------##--------
                dg ------#---------
thrustr0:
                dg ----------------
                dg ------#---------
                dg --#-####--------
                dg ###-#--#--------
                dg --#-#-##--------
                dg ------#---------
thrustr1:
                dg ----------------
                dg ------##--------
                dg ---####---------
                dg #-#--##---------
                dg ---#-##---------
                dg -------#--------
thrustr2:
                dg ----------------
                dg -------#--------
                dg --###-##--------
                dg #--###-#--------
                dg --#-##----------
                dg ------##--------
thrustr3:
                dg ----------------
                dg -----#----------
                dg ---##-##--------
                dg ####-#----------
                dg ---#-#-#--------
                dg ----------------
shipl0:
                dg -----------##-----------
                dg ----------####----------
                dg ---------######---------
                dg ---#--########----------
                dg ###############---------
                dg --------#####-----------
shipl1:
                dg -----------##-----------
                dg ----------####----------
                dg ---------######---------
                dg ----#-########----------
                dg ###############---------
                dg --------#####-----------
shipl2:
                dg -----------##-----------
                dg ----------####----------
                dg ---------######---------
                dg -----#########----------
                dg ###############---------
                dg --------#####-----------
idlel0:       
                dg ----------------
                dg -#--------------
                dg #---------------
                dg #---------------
                dg -#--------------
                dg -#--------------
idlel1:                            
                dg ----------------
                dg #---------------
                dg ##--------------
                dg -#--------------
                dg #---------------
                dg -#--------------
idlel2:                            
                dg ----------------
                dg -#--------------
                dg ----------------
                dg ##--------------
                dg -#--------------
                dg #---------------
idlel3:                            
                dg ----------------
                dg ----------------
                dg -#--------------
                dg ----------------
                dg ##--------------
                dg -#--------------
thrustl0:                          
                dg ----------------
                dg -#--------------
                dg ####-#----------
                dg #--#-###--------
                dg ##-#-#----------
                dg -#--------------
thrustl1:                          
                dg ----------------
                dg ##--------------
                dg -####-----------
                dg -##--#-#--------
                dg -##-#-----------
                dg #---------------
thrustl2:                          
                dg ----------------
                dg #---------------
                dg ##-###----------
                dg #-###--#--------
                dg --##-#----------
                dg ##--------------
thrustl3:                          
                dg ----------------
                dg --#-------------
                dg ##-##-----------
                dg --#-####--------
                dg #-#-#-----------
                dg ----------------

bonus2500:
                dg ####-###-###------------
                dg --##-#---#-#------------
                dg ####-###-#-#------------
                dg ##-----#-#-#------------
                dg ####-###-###------------
bonus2501:
                dg ###-####-###------------
                dg --#-##---#-#------------
                dg ###-####-#-#------------
                dg #-----##-#-#------------
                dg ###-####-###------------
bonus2502:
                dg ###-###-####------------
                dg --#-#---##-#------------
                dg ###-###-##-#------------
                dg #-----#-##-#------------
                dg ###-###-####------------

bonus5000:
                dg ####-###-###------------
                dg ##---#-#-#-#------------
                dg ####-#-#-#-#------------
                dg --##-#-#-#-#------------
                dg ####-###-###------------
bonus5001:
                dg ###-####-###------------
                dg #---##-#-#-#------------
                dg ###-##-#-#-#------------
                dg --#-##-#-#-#------------
                dg ###-####-###------------
bonus5002:
                dg ###-###-####------------
                dg #---#-#-##-#------------
                dg ###-#-#-##-#------------
                dg --#-#-#-##-#------------
                dg ###-###-####------------


; Reserve space for preshifted sprite data

preshiftdata:
                ds (.-spritedatastart)*7

life:
                dg -##-------------
                dg ####------------
                dg ######-#--------
                dg ##########------

smartbomb:
                dg #-###---
                dg -###-#--
                dg #-###---

