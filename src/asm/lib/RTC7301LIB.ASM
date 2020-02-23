;
; RTC-7301DG Driver for KZ80-IOB(PPI)
;                   KUNI-NET 2020
;

PPI_BASE EQU  0C0h
PPI_A    EQU  PPI_BASE+0
PPI_B    EQU  PPI_BASE+1
PPI_C    EQU  PPI_BASE+2
PPI_CTL  EQU  PPI_BASE+3

;
;----------------------------------------------
; RTC7301DG Initialize (for Fos bit ON)
;----------------------------------------------
RTC_INIT:
        PUSH AF
        PUSH BC
        CALL RTC_BANK0
        LD   A,0Eh
        LD   C,0
        CALL RTC_PUT
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
        POP BC
        POP AF
        RET
;
;----------------------------------------------
; 8255PPI Initialize 
;----------------------------------------------
PPI_INIT:
        CALL PPI_B_OUT
        RET
;
;----------------------------------------------
;  8255PPI Initialize - Port-B OUTPUT
;----------------------------------------------
PPI_B_IN:
        PUSH AF
        LD  A,10000010b   ; PORT-A OUT/PORT-B IN/PORT-C OUT
        OUT (PPI_CTL),A
        CALL RTC_WR_OFF
        CALL RTC_RD_OFF
        CALL RTC_CE_OFF
        POP AF
        RET
;
;----------------------------------------------
;  8255PPI Initialize - Port-B Input
;----------------------------------------------
PPI_B_OUT:
        PUSH AF
        LD  A,10000000b   ; PORT-A OUT/PORT-B OUT/PORT-C OUT
        OUT (PPI_CTL),A
        CALL RTC_WR_OFF
        CALL RTC_RD_OFF
        CALL RTC_CE_OFF
        POP AF
        RET
;
;----------------------------------------------
;  RTC Reg DATA get
;==============================================
; IN:
;    A   RTC REG Number
; OUT:
;    A   Data
;----------------------------------------------
RTC_GET:
        CALL PPI_B_IN
        OUT (PPI_A),A
        CALL RTC_RD
        CALL PPI_B_OUT
        RET
;
;----------------------------------------------
;  RTC Reg DATA PUT
;==============================================
; IN:
;    A   RTC REG Number
;    C   Data
;----------------------------------------------
RTC_PUT:
        OUT (PPI_A),A
        LD  A,C
        OUT (PPI_B),A
        CALL RTC_WR
        RET
;
;----------------------------------------------
;  RTC START
;----------------------------------------------
RTC_START:
        PUSH AF
        LD  A,0Fh
        OUT (PPI_A),A
        LD  A,00h
        OUT (PPI_B),A
        CALL RTC_WR
        POP AF
        RET
;----------------------------------------------
;  RTC BANK0 SELECT (RTC STOP)
;----------------------------------------------
RTC_BANK0:
        PUSH AF
        LD  A,0Fh
        OUT (PPI_A),A
        LD  A,02h
        OUT (PPI_B),A
        CALL RTC_WR
        POP AF
        RET
;
;----------------------------------------------
;  RTC BANK1 SELECT (RTC STOP)
;----------------------------------------------
RTC_BANK1:
        PUSH AF
        LD  A,0Fh
        OUT (PPI_A),A
        LD  A,06h
        OUT (PPI_B),A
        CALL RTC_WR
        POP AF
        RET
;
;----------------------------------------------
;  RTC BANK2 SELECT (RTC STOP)
;----------------------------------------------
RTC_BANK2:
        PUSH AF
        LD  A,0Fh
        OUT (PPI_A),A
        LD  A,0Ah
        OUT (PPI_B),A
        CALL RTC_WR
        POP AF
        RET
;
;
;----------------------------------------------
;  Wait Routine
;----------------------------------------------
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
;
;----------------------------------------------
;  RTC Data Write 
;----------------------------------------------
RTC_WR:
        CALL RTC_CE_ON
        CALL RTC_RD_OFF
        CALL RTC_WR_ON
;
        CALL WAIT
;
        CALL RTC_WR_OFF
        CALL RTC_CE_OFF
        RET
;----------------------------------------------
;  RTC Data Read 
;----------------------------------------------
RTC_RD:
        CALL RTC_WR_OFF
        CALL RTC_CE_ON
        CALL RTC_RD_ON
;
        CALL WAIT
;
        IN A,(PPI_B)
        AND 0Fh
        PUSH AF
        CALL RTC_RD_OFF
        CALL RTC_CE_OFF
        POP AF
        RET
;
;----------------------------------------------
;  RTC #CS0 ON/OFF
;----------------------------------------------
RTC_CE_ON:
        LD  A,00001100b
        OUT (PPI_CTL),A
        RET
RTC_CE_OFF:
        LD  A,00001101b
        OUT (PPI_CTL),A
        RET

;
;----------------------------------------------
;  RTC #RD ON/OFF
;----------------------------------------------
RTC_RD_ON:
        LD  A,00001000b         ; #RD ON
        OUT (PPI_CTL),A
        RET
RTC_RD_OFF:
        LD  A,00001001b         ; #RD OFF
        OUT (PPI_CTL),A
        RET
;
;----------------------------------------------
;  RTC #WR ON/OFF
;----------------------------------------------
RTC_WR_ON:
        LD  A,00001010b         ; #WR ON
        OUT (PPI_CTL),A
        RET
RTC_WR_OFF:
        LD  A,00001011b         ; #WR OFF
        OUT (PPI_CTL),A
        RET
