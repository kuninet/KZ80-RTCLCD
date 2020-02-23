;
; RTC7301 READ Utility 
;         KUNI-NET 2020
;
        ORG     0A000h
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
;
        LD  HL,EMSG
        CALL STRPR
;
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
        LD  A,(HL)
        SUB  '0'
        SLA A
        SLA A
        LD  HL,CYOBI
YOBI_LOOP:
        OR A
        JP Z,LOOP_EXIT
        INC HL
        DEC A
        JP YOBI_LOOP
LOOP_EXIT:
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
;-----------------------------------------
; Library Include
;-----------------------------------------
        include "lib/RTC7301LIB.ASM"
        include "lib/KZ80MONLIB.ASM"

;-----------------------------------------
; WORK AREA
;-----------------------------------------
SMSG    DB "*** RTC READ START ***",CR,0
EMSG    DB "*** RTC READ END ***",CR,0
CYOBI   DB " SUN MON TUE WED THU FRI"
STRWK   DS 16
