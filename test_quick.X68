*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $5000        ; end: 5081
START:                  ; first instruction of program
*    BCHG    #$20,(A1)
*    BCHG    D1, (A4)+
*    BCHG    D4,D3
*    BCHG    D3,-(A3)
*    BCHG    #$0293,-(A3)
*    BCHG.L  #%11,D4
*    BCHG.B  #$00FE,$1334
*    BCHG.B  #$F0,(A2)+
*    BCHG.B  #$F3,-(A2) 
*    BCHG.B  #$23,(A5)
*    BCHG    #$F0,(A6)
*    BCHG    #$1234,(A1)
*	MOVE.B  D0, D3
*	MOVE.B  (A0),D3
*	MOVE.B  (A0)+,D3
*	MOVE.B  -(A0),D3
	MOVE.B  #2, D3
	MOVE.B  $3333, D3
	MOVE.B  $44444444, D3
	MOVE.B  D0, $3333
	MOVE.B  D0, $44444444
	MOVE.B  D0, (A3)
	MOVE.B  D0, (A3)+
	MOVE.B  D0, -(A3)
	
*	MOVE.W  D0, D3
*	MOVE.W  (A0),D3
*	MOVE.W  (A0)+,D3
*	MOVE.W  -(A0),D3
*	MOVE.W  #2, D3
*	MOVE.W  $3333, D3
*	MOVE.W  $44444444, D3
*	MOVE.W  D0, $3333
*	MOVE.W  D0, $44444444
*	MOVE.W  D0, A3
*	MOVE.W  D0,    (A3)
*	MOVE.W  D0, (A3)+
*	MOVE.W  D0, -(A3)
*	
*	MOVE.L  D0, D3
*	MOVE.L  (A0),D3
*	MOVE.L  (A0)+,D3
*	MOVE.L  -(A0),D3
*	MOVE.L  $3333, D3
*	MOVE.L  $44444444, D3
*	MOVE.L  D0, $3333
*	MOVE.L  D0, $44444444
*	MOVE.L  D0, A3
*	MOVE.L  D0,    (A3)
*	MOVE.L  D0, (A3)+
*	MOVE.L  D0, -(A3)    

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
