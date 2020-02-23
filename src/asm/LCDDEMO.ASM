;
; LCD SC1602 DEMO
;
;

;=============================================
; MAIN START
;=============================================
;
        ORG     0B000h
;
        LD  HL,SMSG
        CALL STRPR
;
        CALL PPI_INIT
        CALL LCD_INIT
        LD HL,OUTMSG1
        CALL LCD_PRINT
;
        LD DE,0102h
        CALL LCD_LOC
;
        LD HL,OUTMSG2
        CALL LCD_PRINT
;
        LD  HL,EMSG
        CALL STRPR
;
        RET
;
;-------------------------------------
; Lib Include
;-------------------------------------
        include "lib/LCDLIB.ASM"
        include "lib/KZ80MONLIB.ASM"

;-------------------------------------
; WORK AREA
;-------------------------------------
SMSG    DB "*** LCD DEMO START ***",CR,LF,0
EMSG    DB "*** LCD DEMO END ***",CR,LF,0
;
OUTMSG1 DB "Hello LCD SC1602"
OUTMSG2 DB "for KZ80-RTCLCD!"
