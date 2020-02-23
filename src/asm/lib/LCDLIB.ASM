;
; LCD SC1602 Library for KZ80-IOB
;                     KUNI-NET 2020
;
;
;---------------------------------
; 8255PPI Initialize ROUTINE
;---------------------------------
LCD_PPI_INIT:
        CALL PPI_INIT ; COMMON.ASM
        CALL LCD_E_OFF
        CALL LCD_RW_WRITE
        RET

;
;---------------------------------
; LCD PRINT ROUTINE
;=================================
; PARAMETER:
;   HL  Input Buffer Address
;---------------------------------
LCD_PRINT:
        LD B,16
.LOOP:
        LD A,(HL)
        CALL LCD_CHROUT
        INC HL
        DJNZ .LOOP
        RET
;
;---------------------------------
; SC1602 LCD Initialize　ROUTINE
;---------------------------------
LCD_INIT:
        LD A,03Ch
        CALL LCD_CTLOUT
        LD A,0fh
        CALL LCD_CTLOUT
        LD A,01h
        CALL LCD_CTLOUT
        CALL LCD_WAIT
        RET
;
;---------------------------------
; SC1602 LCD cursor LOCATE
;=================================
; PARAMETER:
;  D    X-Pos (1-16)
;  E    Y-Pos (1-2)
;---------------------------------
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
;---------------------------------
; SC1602 LCD Control Output
;=================================
; PARAMETER:
;  A    CTRL CHAR
;---------------------------------
LCD_CTLOUT:
        OUT (PPI_B),A
        CALL LCD_RS_CTL
        CALL LCD_RW_WRITE
        CALL LCD_E_ON
;
        CALL LCD_WAIT
;
        CALL LCD_E_OFF
        RET

;
;---------------------------------
; SC1602 LCD 1Char OUTPUT
;=================================
; PARAMETER:
;  A    OUTPUT CHAR
;---------------------------------
LCD_CHROUT:
        OUT (PPI_B),A
        CALL LCD_RS_DATA
        CALL LCD_RW_WRITE
        CALL LCD_E_ON
;
        CALL LCD_WAIT
;
        CALL LCD_E_OFF
        RET
;
;
;---------------------------------
; WAIT ROUTINE
;=================================
; PARAMETER:
;  A    OUTPUT CHAR
;---------------------------------
LCD_WAIT:
        PUSH BC
        LD C,3
LCD_W_LOOP1:
        LD B,255
LCD_W_LOOP:
        NOP
        DJNZ LCD_W_LOOP
        DEC C
        JR Z,LCD_W_EXIT
        JR  LCD_W_LOOP1
LCD_W_EXIT:
        POP BC
        RET
;---------------------------------
; SC1602 E ON/OFF SELECT
;---------------------------------
LCD_E_ON:
        LD  A,00000101b
        OUT (PPI_CTL),A
        RET
LCD_E_OFF:
        LD  A,00000100b
        OUT (PPI_CTL),A
        RET
;---------------------------------
; SC1602 RS DATA/CTL SELECT
;---------------------------------
LCD_RS_DATA:
        LD  A,00000001b
        OUT (PPI_CTL),A
        RET
LCD_RS_CTL:
        LD  A,00000000b
        OUT (PPI_CTL),A
        RET
;---------------------------------
; SC1602 R/W SELECT
;---------------------------------
LCD_RW_READ:
        LD  A,00000011b
        OUT (PPI_CTL),A
        RET
LCD_RW_WRITE:
        LD  A,00000010b
        OUT (PPI_CTL),A
        RET

;
