*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
LF      EQU     $0A
CR      EQU     $0D

    ORG    $1000
    
START:                  ; first instruction of program

* Put program code here

DISPLAY_MSG 

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


msg_intro   DC.B    "Welcome to the 68k Dissesembler",LF,CR,0
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
