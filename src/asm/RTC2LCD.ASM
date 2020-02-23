;
; RTC7301 READ to SC1602 PRINT Utility 
;         KUNI-NET 2020
;
        ORG     0D000h
;
        LD  HL,SMSG
        CALL STRPR
;
        CALL PPI_INIT
;
; Work Area Initialize
;
        LD HL,STRWK
        LD DE,STRWK+1
        LD BC,16-1
        LD A,0
        LD (HL),A
        LDIR
;
; RTC BANK0 SELECT (RTC START)
;
        CALL RTC_START
;
                
        LD   HL,STRWK
        LD   B,15
        LD   D,0Eh
LOOP:
        LD   A,D
        CALL RTC_GET
        ADD  A,'0'
        LD   (HL),A
        INC  HL
        DEC  D
        DJNZ LOOP
;
        LD   HL,STRWK
        CALL DTOUT
        LD  HL,EMSG
        CALL STRPR
;
        LD  HL,LCDSMSG
        CALL STRPR
        LD   HL,STRWK
        CALL LCDOUT
        LD  HL,LCDEMSG
        CALL STRPR
;
;
        RET
;
;-----------------------------------------
; LCD OUTPUT
;-----------------------------------------
LCDOUT:
        PUSH HL
;
        CALL LCD_PPI_INIT
        CALL LCD_INIT
        CALL EDIT_AREA_CLEAR
;
        POP HL
        CALL EDIT_LCDMSG
;
        LD  HL,LCDWK1
        CALL LCD_PRINT
        LD  DE,0102h
        CALL LCD_LOC
        LD  HL,LCDWK2
        CALL LCD_PRINT
        RET
;
;-----------------------------------------
; LCD OUTPUT
;-----------------------------------------
EDIT_AREA_CLEAR:
        PUSH HL
        PUSH DE
        PUSH BC
        LD HL,LCDWK1
        LD BC,LCDWK1_LEN-1
        CALL AREA_CLEAR
        LD HL,LCDWK2
        LD BC,LCDWK2_LEN-1
        CALL AREA_CLEAR
        POP BC
        POP DE
        POP HL
        RET
;
AREA_CLEAR:
        LD A,' '
        LD (HL),A 
        PUSH HL
        POP DE
        INC DE
        LDIR
        RET
;
;-----------------------------------------
; LCD MSG EDIT
;-----------------------------------------
EDIT_LCDMSG:
        LD  HL,STRWK
        LD  DE,LCDWK1
;
        LD  BC,4
        LDIR
        CALL EDIT_SLA
        LD  BC,2
        LDIR
        CALL EDIT_SLA
        LD  BC,2
        LDIR
;
        PUSH HL
        CALL YOBI_SEL
        LD  BC,4
        LDIR
        POP HL
        INC HL
;
        LD  DE,LCDWK2
        LD  BC,2
        LDIR
        CALL EDIT_COL
        LD  BC,2
        LDIR
        CALL EDIT_COL
        LD  BC,2
        LDIR
        RET
;
EDIT_COL:
        LD  A,':'
        JP EDIT_WK
EDIT_SPC:
        LD  A,' '
        JP EDIT_WK
EDIT_SLA:
        LD  A,'/'
EDIT_WK:
        LD  (DE),A
        INC DE
        RET
;-----------------------------------------
; DATE/TIME OUTPUT
;-----------------------------------------
DTOUT:
;
; DATE PRINT
;
        LD  B,4
        CALL NSTRPR
        LD  A,'/'
        CALL CPRINT
        LD  B,2
        CALL NSTRPR
        LD  A,'/'
        CALL CPRINT
        LD  B,2
        CALL NSTRPR
;
; YOBI PRINT
;
        PUSH HL
        CALL YOBI_SEL
        LD  B,4
        CALL NSTRPR
        POP HL
        INC HL
;
; TIME PRINT
;
        CALL SPC_PRINT
        LD  B,2
        CALL NSTRPR
        LD  A,':'
        CALL CPRINT
        LD  B,2
        CALL NSTRPR
        LD  A,':'
        CALL CPRINT
        LD  B,2
        CALL NSTRPR
        CALL CRLF_PRINT
        RET
;
YOBI_SEL:
        LD  A,(HL)
        SUB  '0'
        SLA A
        SLA A
        LD  HL,CYOBI
YOBI_LOOP:
        OR A
        RET Z
        INC HL
        DEC A
        JP YOBI_LOOP
;
;-----------------------------------------
; Library Include
;-----------------------------------------
        include "lib/COMMON.ASM"
        include "lib/LCDLIB.ASM"
        include "lib/RTC7301LIB.ASM"
        include "lib/KZ80MONLIB.ASM"

;-----------------------------------------
; WORK AREA
;-----------------------------------------
SMSG    DB "*** RTC READ START ***",CR,0
EMSG    DB "*** RTC READ END ***",CR,0
LCDSMSG    DB "*** LCD PRINT START ***",CR,0
LCDEMSG    DB "*** LCD PRINT END ***",CR,0
CYOBI   DB " SUN MON TUE WED THU FRI"
STRWK   DS 16
;
LCDWK1  DS 16
LCDWK1_LEN EQU $-LCDWK1
;
LCDWK2  DS 16
LCDWK2_LEN EQU $-LCDWK2

