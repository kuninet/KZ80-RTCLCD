;
; LCD/RTC COMMON ROUTINE
;       KUNI-NET 2020
;

PPI_BASE EQU  0C0h
PPI_A    EQU  PPI_BASE+0
PPI_B    EQU  PPI_BASE+1
PPI_C    EQU  PPI_BASE+2
PPI_CTL  EQU  PPI_BASE+3

;
;---------------------------------
; 8255PPI Initialize ROUTINE
;---------------------------------
PPI_INIT:
        LD  A,10000000b   ; PORT-A OUT/PORT-B OUT/PORT-C OUT
        OUT (PPI_CTL),A
        LD  A,0FFh
        OUT (PPI_C),A
        RET

