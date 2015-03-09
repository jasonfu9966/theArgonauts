*-----------------------------------------------------------
* Title      : Final Project test
* Written by : Jason FUUUU
* Date       : 02/15/2015
* Description: intend to input data into memory location. 
*-----------------------------------------------------------

    ORG         $00005000
START

TEST_TOP        RTS

*-MOVE opcode-----------------------------------
    
    *---MOVE.B
    MOVE.B  #101,D1
    MOVE.B  $48,D2
    MOVE.B  #$AA,D1
    MOVE.B  D1,(A6)+
    MOVE.B  D0,(A2)
    MOVE.B  D0,-(A0)
    MOVE.B  (A1), D1
    MOVE.B  (A1)+,D1
    MOVE.B  -(A1),D1
    MOVE.B  #$40,D2
    MOVE.B  D0,D1
    MOVE.B  D0, $E111
    MOVE.B  D0, $E1234560
 
    *---MOVE.W
    MOVE.W  #1201,D1
    MOVE.W  $418,D2
    MOVE.W  #$ABA,D1
    MOVE.W  D1,(A6)+
    MOVE.W  D0,(A2)
    MOVE.W  D0,-(A0)
    MOVE.W  (A1), D1
    MOVE.W  (A1)+,D1
    MOVE.W  -(A1),D1
    MOVE.W  #$4120,D2
    MOVE.W  D0,D1
    MOVE.W  D0, $AE111
    MOVE.W  D0, $E1234
    
    *---MOVE.L
    MOVE.L  #1201,D1
    MOVE.L  $418,D2
    MOVE.L  #$ABA,D1
    MOVE.L  D1,(A6)+
    MOVE.L  D0,(A2)
    MOVE.L  D0,-(A0)
    MOVE.L  (A1), D1
    MOVE.L  (A1)+,D1
    MOVE.L  -(A1),D1
    MOVE.L  #$4120,D2
    MOVE.L  D0,D1
    MOVE.L  D0, $AE111
    MOVE.L  D0, $E1234
    
*--MOVEM OPCODE----------------------
    MOVEM.L D0-D7/A0-A6,$1234
    MOVEM.L (A5),D0-D2/D5-D7/A0-A3/A6
    MOVEM.W (A7)+,D0-D5/D7/A0-A6
    MOVEM.W D0-D5/D7/A0-A6,-(A7)  
    
*-MOVEQ opcode-----------------------
    *----MOVEQ.L
*    MOVEQ.L  #%11001,A1
*    MOVEQ.L  $4180AABB,A2
*    MOVEQ.L  #$ACAA,A1
*    MOVEQ.L  21031,A4
*    MOVEQ.L  D1,A6
*    MOVEQ.L  A2,A2
*    MOVEQ.L  D0,A0
*    MOVEQ.L  (A1), A2
*    MOVEQ.L  (A1)+,A2
*    MOVEQ.L  -(A1),A2
    
*---ADD Opcode-----------------------
*---ADD.B
    ADD.B  $48,D2
    ADD.B  #$AA,D1
    ADD.B  D1,(A6)+
    ADD.B  D0,(A2)
    ADD.B  D0,-(A0)
    ADD.B  #$40,D2
    ADD.B  D0, $E111
    ADD.B  D0, $E1234560	
*---ADD.W
    ADD.W  #101,A1
    ADD.W  $48,D2
    ADD.W  #$AA,D1
    ADD.W  D1,(A6)+
    ADD.W  D0,(A2)
    ADD.W  D0,-(A0)
    ADD.W  (A1), A2
    ADD.W  (A1)+,A2
    ADD.W  -(A1),A2
    ADD.W  #$40,D2
    ADD.W  D0,A1
    ADD.W  D0, $E111
    ADD.W  D0, $E1234560
*---ADD.L
    ADD.L   D5,$11111111

*---ADDA
    ADDA.W  #101,A1
    ADDA.W  D0,A1
*    ADDA.W  D0, $E111
*    ADDA.W  D0, $E1234560
    ADDA.L  #101,A1
    ADDA.L  #$101,A1

*---ADDQ
    ADDQ.B  #1,D1
    ADDQ.B  #1,D1
    ADDQ.W  #$1,D1
    ADDQ.W  #1, $E111
    ADDQ.W  #1, $E1234560
    ADDQ.L  #$1,D1
    
*---SUB Opcode-----------------------
*---SUB
    SUB.B  #1,D1
    SUB.B  #1,D1
    SUB.W  #$1,D1
    SUB.W  #1, $E111
    SUB.W  #1, $E1234560
    SUB.L  #$1,D1
*---SUBA
    SUBA.W  A1,A1
    SUBA.W  D1,A2
    SUBA.W  #$1,A3
    SUBA.W  #1, A1
    SUBA.L  #$1,A2
*---SUBI
    SUBI.B  #1,D1
    SUBI.B  #1,$1234
    SUBI.W  #1,$1234
    SUBI.W  #1,D1
    SUBI.W  #$1,D1
    SUBI.W  #1, $1234
    SUBI.L  #$1, $1234

*---MULS, DIVS Opcode-----------------------
*---MULS
    MULS.W  #1,D1
    MULS.W  D0,D1
    MULS.W  #$00001,D0
    MULS.W  #$1,D1
    MULS.W  D0, D1

*---MULS.L
*    MULS.L  #1, D1
*    MULS.L  D0, D1
*    MULS.L  #$000001, D0
*    MULS.L  #$1,    D1
*    MULS.L  D0, D1

*---DIVS
    DIVS    D0,D1
    DIVS    #$1000,D0
    DIVS    (A0),D1
    DIVS    $11111111,D4  

*---LEA, CLR Opcode-----------------------
*---LEA
    LEA.L  $1000,A0
    LEA  $1001,A0
    LEA  $00001,A1

*---CLR------
    CLR.B   (A0)
    CLR.W   (A0)
    CLR.L   (A0)
    CLR.B   D0
    CLR.W   D0   
    CLR.L   D0
    CLR.B   $0001
    CLR.W   $0011
    CLR.L   $0001  
    CLR.B   $AAAA
    CLR.W   $BBBB
    CLR.L   $CCCC

*---AND, ANDI, EOR, EORI Opcode------------------
*---AND-----
    AND.B   $11,D5
    AND.W   $1111,D5
    AND.L   $11111111,D5
    AND.B   $1111,D5
    AND.W   $11111111,D5  
    AND.B   D5,$11
    AND.W   D5,$1111
    AND.L   D5,$11111111
         
*----ANDI----
    ANDI    #%10000111,D7
    ANDI    #$FE00,$1234
    ANDI.B  #$F0,(A2)+
    ANDI.w  #$F0,-(A2) 
    ANDI.L  #$F0,(A2)
    ANDI    #$F0,(A2)
    ANDI    #$1234,(A2)

*----EOR---------
    EOR.B #%00000011,(A0)+
    EOR.B #%00000011,-(A0)
    EOR.B #%00000011,(A0)
    EOR.W #$F001,D0
    EOR.L #$11111111,D0
    
*----EORI--------
    EORI    #%10000111,D7
    EORI    #$FE00,$1234
    EORI.B  #$F0,(A2)+
    EORI.w  #$F0,-(A2) 
    EORI.L  #$F0,(A2)
    EORI    #$F0,(A2)
    EORI    #$123,(A2) 

*---LSL, LSR, ASL, ASR, ROL, ROR, BCHG
*---LSL--------
	LSL.B		#1, D0
	LSL.W	    #1, D0
	LSL.L		#1, D0

	LSL.B		D1, D0
	LSL.W   	D1, D0
	LSL.L		D1, D0
    
*---LSR--------
	LSR.B		#1, D0
	LSR.W	    #1, D0
	LSR.L		#1, D0

	LSR.B		D1, D0
	LSR.W   	D1, D0
	LSR.L		D1, D0

*---ASL--------
    ASL.B       #1, D0
    ASL.W       #1, D0
    ASL.L       #1, D0
    
    ASL.B       D1, D0
    ASL.W       D1, D0
    ASL.L       D1, D0    
    
*---ASR--------
    ASR.B       #1, D0
    ASR.W       #1, D0
    ASR.L       #1, D0
    
    ASR.B       D1, D0
    ASR.W       D1, D0
    ASR.L       D1, D0   
    
*---ROL--------
    ROL.B   D0,D2
    ROL.B   #7,D4
    ROL.L   #8,D4
    ROL.W   -(a6)
    ROL.W   (a4)+ 
    
*---ROR--------
    ROR.W   #6,D0
    ROR.L   D0,D2
    ROR.W   $0FF00000 ; 
    ROR.W   (a4)+
    
*---BCHG-------
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
    
*---CMP, CMPA, CMPI
*---CMP
    CMP     D0,D1
    CMP     A1,D2
    CMP     (A2)+,D3
    CMP     -(A2),D3
    CMP     (A3),D4
    CMP     #$1002,D5
    CMP     1110,D6

*---CMPA
    CMPA.L   A0,A1
    CMPA.W   $1000,A1
    CMPA.L   #$1000,A4
    CMPA.W   (A2)+,A6
    CMPA.L   D5,A2
    CMPA.L   -(A2),A3
    CMPA.L   (A2),A3
    
*---CMPI
    CMPI.B     #$12,(A4)
    CMPI.W     #$1234,-(A3)
    CMPI.L     #$1002,(A3)+
    CMPI.W     #1110,(A6)  
    CMPI       #$2000,D1 
    
*---BCC, BGT, BLE, BVS
*----------BCC PASS----------------------     
    MOVE.L  #$101,D1
    ADD.L   #$89,D1
    BCC     TEST_TOP
    MOVE.B  #4,D0
    MOVE.B  #6,D1
    CMP.B   D0,D1
    MOVE.L  #$101,D1
    ADD.L   #$89,D1
    BCC     TEST_BOT
    
*----------BGT PASS----------------------
    MOVE.B  #4,D0
    MOVE.B  #6,D1
    CMP.B   D0,D1
    BGT     TEST_TOP
    MOVE.L  #$04,D0  
    MOVE.L  #$06,D1
    CMP.B   D0,D1
    BGT     TEST_BOT

*----------BLE PASS---------------------  
    MOVE.B  #$04,D0
    MOVE.B  #$06,D1
    CMP.B   D0,D1
    BLE     TEST_TOP
    MOVE.L  #$04,D0  
    MOVE.L  #$06,D1
    CMP.B   D0,D1
    BLE     TEST_BOT

*---------BVS PASS------------------------
    MOVE.W #$A000,D1
    ADD.W  #$A000,D1
    BVS    TEST_TOP
    MOVE.B  #4,D0
    MOVE.B  #6,D1
    CMP.B   D0,D1
    MOVE.W #$A000,D1
    ADD.W  #$A000,D1
    BVS    TEST_BOT

*-------JRS, RTS, BRA-------------
   JSR      $0000
   JSR      $A000
   JSR      (A4)
   JSR      DUMB
DUMB        RTS 

*------BRA ---------------------
    MOVE.W  #$A000, D1
    BRA     TEST_TOP
    BRA     TEST_BOT
    
TEST_BOT            RTS
     END           START













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
