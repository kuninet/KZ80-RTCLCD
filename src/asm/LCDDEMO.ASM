;
; LCD SC1602 DEMO
;
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
LCD_PRINT:
        LD B,16
LOOP:
        LD A,(HL)
        CALL LCD_CHROUT
        INC HL
        DJNZ LOOP
        RET
;
PPI_INIT:
        CALL PPI_B_OUT
        CALL RTC_WR_OFF
        CALL RTC_RD_OFF
        CALL RTC_CE_OFF
;
        CALL LCD_E_OFF
        CALL LCD_RW_WRITE
;
        RET
;
PPI_B_IN:
        LD  A,10000010b   ; PORT-A OUT/PORT-B IN/PORT-C OUT
        OUT PPI_CTL,A
        RET
;
PPI_B_OUT:
        LD  A,10000000b   ; PORT-A OUT/PORT-B OUT/PORT-C OUT
        OUT PPI_CTL,A
        RET
;
RTC_GET:
        LD D,A
        CALL PPI_B_IN
        LD A,D
        OUT PPI_A,A
        CALL RTC_RD
        LD D,A
        CALL PPI_B_OUT
        LD A,D
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
        CALL RTC_WR_ON
        NOP
        NOP
        CALL RTC_WR_OFF
        CALL RTC_CE_OFF
        RET
RTC_RD:
        CALL RTC_CE_ON
        CALL RTC_RD_ON
        NOP
        NOP
        IN A,PPI_B
        AND 0Fh
        LD D,A
        CALL RTC_RD_OFF
        CALL RTC_CE_OFF
        LD A,D
        RET
;
LCD_INIT:
        LD A,03Ch
        CALL LCD_CTLOUT
        LD A,0fh
        CALL LCD_CTLOUT
        LD A,01h
        CALL LCD_CTLOUT
        CALL WAIT
        RET
;
LCD_LOC:
        LD A,E
        CP 1
        JP Z,LCD_LOC1
        LD A,40h
        JP LCD_LOC2
LCD_LOC1:
        LD A,0
LCD_LOC2:
        ADD A,80h
        ADD A,D
        DEC A
        CALL LCD_CTLOUT
        RET
;
LCD_CTLOUT:
        OUT (PPI_B),A
        CALL LCD_RS_CTL
        CALL LCD_RW_WRITE
        CALL LCD_E_ON
;
        CALL WAIT
;
        CALL LCD_E_OFF
        RET

LCD_CHROUT:
        OUT (PPI_B),A
        CALL LCD_RS_DATA
        CALL LCD_RW_WRITE
        CALL LCD_E_ON
;
        CALL WAIT
;
        CALL LCD_E_OFF
        RET
;
WAIT:
        PUSH BC
        LD C,3
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
LCD_E_ON:
        LD  A,00000101b
        OUT (PPI_CTL),A
        RET
LCD_E_OFF:
        LD  A,00000100b
        OUT (PPI_CTL),A
        RET

LCD_RS_DATA:
        LD  A,00000001b
        OUT (PPI_CTL),A
        RET
LCD_RS_CTL:
        LD  A,00000000b
        OUT (PPI_CTL),A
        RET

LCD_RW_READ:
        LD  A,00000011b
        OUT (PPI_CTL),A
        RET
LCD_RW_WRITE:
        LD  A,00000010b
        OUT (PPI_CTL),A
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
;
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
;
; WORK AREA
SMSG    DB "*** LCD DEMO START ***",CR,LF,0
EMSG    DB "*** LCD DEMO END ***",CR,LF,0
;
OUTMSG1 DB "Hello LCD SC1602"
OUTMSG2 DB "for KZ80-RTCLCD!"
