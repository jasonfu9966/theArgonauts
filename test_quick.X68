*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $5000        ; end: 5081
START:                  ; first instruction of program
    BCHG    #$20,(A1)
    BCHG    D1, (A4)+
    BCHG    D4,D3
    BCHG    D3,-(A3)
    BCHG    #$0293,-(A3)
    BCHG.L  #%11,D4
    BCHG.B  #$00FE,$1334
    BCHG.B  #$F0,(A2)+
    BCHG.B  #$F3,-(A2) 
    BCHG.B  #$23,(A5)
    BCHG    #$F0,(A6)
    BCHG    #$1234,(A1)
*
*    ANDI    #%10000111,D7
*    ANDI    #$FE00,$1234
*    ANDI.B  #$F0,(A2)+
*    ANDI.w  #$F0,-(A2) 
*    ANDI.L  #$F0,(A2)
*    ANDI    #$F0,(A2)
*    ANDI    #$1234,(A2)
*    
*    SUBI.B  #1,D1
*    SUBI.B  #1,$1234
*    SUBI.W  #1,$1234
*    SUBI.W  #1,D1
*    SUBI.W  #$1,D1
*    SUBI.W  #1, $1234
*    SUBI.L  #$1, $1234
*
*
*    EORI    #%10000111,D7
*    EORI    #$FE00,$1234
*    EORI.B  #$F0,(A2)+
*    EORI.w  #$F0,-(A2) 
*    EORI.L  #$F0,(A2)
*    EORI    #$F0,(A2)
*    EORI    #$123,(A2) 

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
