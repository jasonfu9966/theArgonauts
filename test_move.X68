*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $5000        ; end: 5081
START:                  ; first instruction of program
        ;       destination data no work
	MOVE.B  #2, D3                  *causes crash
	MOVE.B  $3333, D3
	MOVE.B  $44444444, D3
	MOVE.B  D0, $3333               *no worko
	MOVE.B  D0, $44444444
	MOVE.B  D0, (A3)
	MOVE.B  D0, (A3)+
	MOVE.B  D0, -(A3)
	
	MOVE.W  D0, D3
	MOVE.W  (A0),D3
	MOVE.W  (A0)+,D3
	MOVE.W  -(A0),D3
	MOVE.W  #2, D3
	MOVE.W  $3333, D3
	MOVE.W  $44444444, D3
	MOVE.W  D0, $3333
	MOVE.W  D0, $44444444
	MOVE.W  D0, A3
	MOVE.W  D0,    (A3)
	MOVE.W  D0, (A3)+
	MOVE.W  D0, -(A3)
	
	MOVE.L  D0, D3
	MOVE.L  (A0),D3
	MOVE.L  (A0)+,D3
	MOVE.L  -(A0),D3
	MOVE.L  $3333, D3
	MOVE.L  $44444444, D3
	MOVE.L  D0, $3333
	MOVE.L  D0, $44444444
	MOVE.L  D0, A3
	MOVE.L  D0,    (A3)
	MOVE.L  D0, (A3)+
	MOVE.L  D0, -(A3)    

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
