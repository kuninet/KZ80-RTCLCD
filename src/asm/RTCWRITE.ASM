;
; RTC7301 WRITE Utility
;     KUNI-NET 2020
;-----------------------------------------
; MAIN START
;-----------------------------------------
;
        ORG     09000h
;
        LD   HL,SMSG
        CALL STRPR
;
        CALL PPI_INIT
        CALL RTC_BANK0
;
; INPUT PARAM GET
;
        INC DE
        INC DE
        LD  A,(DE)
        LD  L,A
        INC DE
        LD  A,(DE)
        LD  H,A
;
        CALL STRLEN
        CP   15
        JP   NZ,ERROREND
        LD   DE,OUTDATA
        LD   BC,15
        LDIR
;
; Fos FLAG ON Check (Low Voltage)
;
        LD   A,1
        CALL RTC_GET
        BIT  3,A     ; Fos FLAG ON?
        CALL NZ,RTC_INIT_CALL
;
; RTC OUTPUT
;
        LD   HL,OUTDATA
        LD   B,15      ; DATA COUNT
        LD   D,0Eh     ; START RTC REG
LOOP:
        LD   A,(HL)
        SUB  '0'
        LD   C,A
        LD   A,D
        CALL RTC_PUT
        INC  HL
        DEC  D
        DJNZ LOOP
;
        CALL RTC_START
;
        LD   HL,EMSG
        CALL STRPR
;
        RET
;-------------------------------
; RTC 初期化呼び出し
;-------------------------------
RTC_INIT_CALL:
        LD HL,I_SMSG
        CALL STRPR
        CALL RTC_INIT
        LD HL,I_EMSG
        CALL STRPR
        RET
;
;-------------------------------
;エラー終了
;-------------------------------
ERROREND:
        LD HL,ERRMSG
        CALL STRPR
        RET

;-----------------------------------------
; Library Include
;-----------------------------------------
        include "lib/RTC7301LIB.ASM"
        include "lib/KZ80MONLIB.ASM"

;-----------------------------------------
; WORK AREA
;-----------------------------------------
SMSG DB "** RTC WRITE START **",CR,0
EMSG DB "** RTC WRITE END **",CR,0
I_SMSG DB "** RTC INIT START **",CR,0
I_EMSG DB "** RTC INIT END **",CR,0
ERRMSG DB "** ERROR INPUT PARAM : YYYYMMDDyHHMMDD (15char)",CR,0
OUTDATA DS 15