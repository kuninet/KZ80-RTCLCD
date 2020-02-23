;
; RTC7301 INIT PROGRAM
;       KUNI-NET 2020
;
;---------------------------------------
; MAIN START
;---------------------------------------
        ORG     0C000h
;
        CALL PPI_INIT
        CALL RTC_INIT
        CALL RTC_START
;
        RET
;
;---------------------------------------
; Library Include
;---------------------------------------
        include "lib/COMMON.ASM"
        include "lib/RTC7301LIB.ASM"
        include "lib/KZ80MONLIB.ASM"
        
;---------------------------------------
; Work Area
;---------------------------------------
;
SMSG DB "** RTC INIT START **",CR,0
EMSG DB "** RTC INIT END **",CR,0
