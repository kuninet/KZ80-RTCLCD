;
; RTC7301 WRITE TEST
;
CR		EQU	0DH
LF		EQU	0AH
ESC		EQU	1BH
CTRLC	EQU	03H
CLS		EQU	0CH
SPC		EQU	20h
NULL	EQU 00h
BEEP	EQU 07h
BS		EQU 08h
TAB		EQU 09h
DEL		EQU 7Fh
;
PPI_BASE EQU  0C0h
PPI_A    EQU  PPI_BASE+0
PPI_B    EQU  PPI_BASE+1
PPI_C    EQU  PPI_BASE+2
PPI_CTL  EQU  PPI_BASE+3
;
        ORG     09000h
;
        LD   HL,SMSG
        CALL STRPR
;
        CALL PPI_INIT
;
        CALL RTC_BANK0
; INPUT PARAM GET
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
;
        LD   B,15
        LD   D,0Eh
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
;エラー終了
;-------------------------------
ERROREND:
        LD HL,ERRMSG
        CALL STRPR
        RET
;
;------------------------------------
; (strlen) 文字列長をAレジスタへ返す
;------------------------------------
STRLEN:
	PUSH HL
	PUSH BC
	LD C,0
_STR_LEN_LOOP:
	LD A,(HL)
	CP NULL
	JR Z,_STR_LEN_EXIT
	INC HL
	INC C
	JR _STR_LEN_LOOP
;
_STR_LEN_EXIT:
	LD A,C
	POP BC
	POP HL
	RET
;
;
PPI_INIT:
        CALL PPI_B_OUT
;
        CALL RTC_RD_OFF
        CALL RTC_WR_OFF
;
        CALL RTC_CE_OFF
        RET
;
;
WAIT:
        PUSH BC
        LD C,1
W_LOOP1:
        LD B,255
W_LOOP:
        NOP
        DJNZ W_LOOP
        DEC C
        JR Z,W_EXIT
        JR  W_LOOP1
W_EXIT:
        POP BC
        RET
;
PPI_B_IN:
        LD  A,10000010b   ; PORT-A OUT/PORT-B IN/PORT-C OUT
        OUT PPI_CTL,A
        CALL RTC_RD_OFF
        CALL RTC_WR_OFF
        CALL RTC_CE_OFF

        RET
;
PPI_B_OUT:
        LD  A,10000000b   ; PORT-A OUT/PORT-B OUT/PORT-C OUT
        OUT PPI_CTL,A
        CALL RTC_RD_OFF
        CALL RTC_WR_OFF
        CALL RTC_CE_OFF
        RET
;
RTC_GET:
        OUT PPI_A,A
        CALL RTC_RD
        RET
;
RTC_PUT:
        OUT PPI_A,A
        LD  A,C
        OUT PPI_B,A
        CALL RTC_WR
        RET
;
RTC_START:
        LD  A,0Fh
        OUT PPI_A,A
        LD  A,00h
        OUT PPI_B,A
        CALL RTC_WR
        RET
;
RTC_BANK0:
        LD  A,0Fh
        OUT PPI_A,A
        LD  A,02h
        OUT PPI_B,A
        CALL RTC_WR
        RET
;
RTC_BANK1:
        LD  A,0Fh
        OUT PPI_A,A
        LD  A,06h
        OUT PPI_B,A
        CALL RTC_WR
        RET
;
RTC_BANK2:
        LD  A,0Fh
        OUT PPI_A,A
        LD  A,0Ah
        OUT PPI_B,A
        CALL RTC_WR
        RET
;
RTC_WR:
        CALL RTC_CE_ON
        CALL RTC_RD_OFF
        CALL RTC_WR_ON
        CALL RTC_WR_OFF
        CALL RTC_CE_OFF
        RET
RTC_RD:
        CALL RTC_CE_ON
        CALL RTC_WR_OFF
        CALL RTC_RD_ON
        IN A,PPI_B
        AND A,0Fh
        PUSH AF
        CALL RTC_RD_OFF
        CALL RTC_WR_OFF
        CALL RTC_CE_OFF
        POP  AF
        RET
;
RTC_CE_ON:
        LD  A,00001100b
        OUT PPI_CTL,A
        RET
RTC_CE_OFF:
        LD  A,00001101b
        OUT PPI_CTL,A
        RET
;
RTC_RD_ON:
        LD  A,00001000b         ; #RD ON
        OUT PPI_CTL,A
        RET
RTC_RD_OFF:
        LD  A,00001001b         ; #RD OFF
        OUT PPI_CTL,A
        RET
RTC_WR_ON:
        LD  A,00001010b         ; #WR ON
        OUT PPI_CTL,A
        RET
RTC_WR_OFF:
        LD  A,00001011b         ; #WR OFF
        OUT PPI_CTL,A
        RET
RTC_INIT:
        CALL RTC_BANK0
        LD   A,0Eh
        LD   C,0
        CALL RTC_BANK1
        LD   A,0Eh
        LD   C,0
        CALL RTC_PUT
        LD   A,0Bh
        LD   C,4
        CALL RTC_PUT
        LD   A,0Ch
        LD   C,0
        CALL RTC_PUT
        LD   A,0Dh
        LD   C,8
        CALL RTC_PUT
;
        CALL RTC_BANK2
        LD   A,01h
        LD   C,0
        CALL RTC_PUT
        LD   A,03h
        LD   C,0
        CALL RTC_PUT
        LD   A,05h
        LD   C,0
        CALL RTC_PUT
        LD   A,06h
        LD   C,0
        CALL RTC_PUT
        LD   A,08h
        LD   C,0
        CALL RTC_PUT
        CALL RTC_BANK0
        RET
;------------------------------------------------------------------------------
; 文字列出力
;------------------------------------------------------------------------------
STRPR:
    LD A,(HL)
    OR A
    RET Z
    CALL CPRINT
    INC HL
    JR STRPR
;------------------------------------------------------------------------------
; 文字出力 (CRLF対応)
; IN: A - キャラクタ
; RET: なし
;------------------------------------------------------------------------------
CPRINT:
    CP 0Dh
    JR Z,CRLF_PRINT
    RST 08h
    RET

;------------------------------------------------------------------------------
; CRLF出力 (CRLF対応)
;------------------------------------------------------------------------------
CRLF_PRINT:
    LD A,0DH
    RST 08H
    LD A,0AH
    RST 08h
    RET

;------------------------------------------------------------------------------
; ブランク出力 
;------------------------------------------------------------------------------
SPC_PRINT:
    LD A,SPC
    RST 08H
    RET

SMSG DB "** RTC WRITE START **",CR,LF,0
EMSG DB "** RTC WRITE END **",CR,LF,0
ERRMSG DB "** ERROR INPUT PARAM : YYYYMMDDyHHMMDD (15char)",CR,LF,0