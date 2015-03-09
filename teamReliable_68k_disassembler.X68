/*-----------------------------------------------------------
* Title      :      EASY68K DISASSEMBLER
* Written by :      NICHOLAS ABEL AND JASON FU
* Date       :      MARCH 2015
* Description:
*----------------------------------------------------------

*===Preprocessor Instructions===*

LF      EQU     $0A *New Line (Line Feed)
CR      EQU     $0D *Carriage Return

STACK   EQU     $A000

SHIFT10 EQU     10
SHIFT11 EQU     11
SHIFT12 EQU     12
SHIFT13 EQU     13

*===Code Body===*

        ORG    $1000
    
START   JSR     ClearAll
        JSR     LoadStackJump
        JSR     Intro
        JSR     GetStartAddr
        JSR     GetEndAddr
        JSR     LoadStartAddr
        JSR     MainLoop
        JMP     End
        
*===Main Routines===*

ClearAll
        CLR.B   var_num_displayed
        CLR.L   var_start_addr
        CLR.L   var_end_addr
        RTS

LoadStackJump
        LEA     STACK,  SP
        LEA     JmpTable,   A0
        RTS
        
*----------------------------------------------------------------
*              OpCode JUMP Table                                |
*----------------------------------------------------------------

JmpTable 

               JMP         code0000

               JMP         code0001

               JMP         code0010

               JMP         code0011

               JMP         code0100

               JMP         code0101

               JMP         code0110

               JMP         code0111

               JMP         code1000

               JMP         code1001

               JMP         code1010

               JMP         code1011

               JMP         code1100

               JMP         code1101

               JMP         code1110

               JMP         code1111

*----------------------------------------------------------------
*              OpCode Routine Jump Table                        |
*----------------------------------------------------------------

code0000       *JSR          GroupZero
*               BRA          continueMain

code0001       *JSR          MoveByte
*               BRA          continueMain
               
code0010       *JSR          MoveLong               
*               BRA          continueMain

code0011       *JSR          MoveWord
*               BRA          continueMain

code0100       *JSR          code0100Decode
*               BRA          continueMain

code0101       *JSR          code0101Decode
*               BRA        continueMain

code0110       *JSR          BranchGroup
*               BRA        continueMain

code0111       *JSR          outBadData
*               BRA          continueMain

code1000       *JSR          code1000Decode
*               BRA          continueMain
                
              
code1001       *JSR          code1001Decode
*               BRA          continueMain

code1010       *JSR          outBadData
*               BRA          continueMain
 
code1011       *JSR          code1011Decode
*               BRA          continueMain

code1100       *JSR          code1100Decode
*               BRA          continueMain


code1101       *JSR          AddGroup
*               BRA          continueMain

code1110       *JSR          BitShiftGroup
*               BRA          continueMain

code1111       *JSR          outBadData
*               BRA          continueMain

*----------------------------------------------------------------
*              END JMP AND ROUTINE TABLE                        |
*----------------------------------------------------------------

Intro
        LEA     msg_intro, A1
        JSR     Helper_DisplayMsg
        RTS

GetStartAddr    *Used:  A1, D2, D6

        LEA     msg_start_request,  A1
        JSR     Helper_DisplayMsg
        LEA     var_start_addr,     A1
        JSR     Helper_GetInput
        JSR     Helper_CharToHex
        CLR.L   var_start_addr
        MOVE.L  D4,                 var_start_addr
        CLR     D4
        RTS

GetEndAddr      *Used

        LEA     msg_end_request,    A1
        JSR     Helper_DisplayMsg
        LEA     var_end_addr,       A1
        JSR     Helper_GetInput
        JSR     Helper_CharToHex
        CLR.L   var_end_addr
        MOVE.L  D4,                 var_end_addr
        CLR     D4
        RTS

LoadStartAddr
        MOVE.L  var_start_addr, A5
        RTS

*===Main Loop Routines===*

MainLoop
        JSR     DisplayedTenLinesYet
        JMP     CheckPositionAgainstEnd
        
CheckPositionAgainstEnd
        CMPA.L  var_end_addr,   A5
        BGE     EndReached
        BRA     MainLoopCont
        
MainLoopCont
        JSR     Buffer_LoadBuffer
        JSR     Buffer_BufferAddress
        JSR     LoadOpCode

EndReached
        *Go Again
        *Yes JMP START                       ;--------------------------------------
        *No  JMP end
        
*===Main Loop Sub-Routines===*

LoadLineAddr
        MOVE.L  A5,     var_line_addr
        RTS

DisplayedTenLinesYet
        CMP.B   #10,    var_num_displayed
        BLT     LessThanTenLines
        LEA     msg_continue_request,   A1
        JSR     Helper_DisplayMsg
        CLR.B   var_num_displayed
LessThanTenLines
        RTS

LoadOpCode
        CLR     D5
        MOVE.W  (A5)+,  D5
        MOVE.W  D5,     var_opcode_op
        CLR     D0
        MOVE.W  D5,     D0
        MOVE.B  #12,    D1
        LSR.W   D1,     D0
        MULU    #6,     D0
        JSR     0(A0,D0)

*===Helper Routines===*

*--Helper: DisplayMsg--*

Helper_DisplayMsg

        MOVE.B  #13,    D0
        TRAP    #15
        CLR     D0
        RTS
        
Helper_GetInput

        MOVE.B  #2,     D0
        TRAP    #15
        CLR     D0
        RTS

*--Helper: CharToHex--*

Helper_CharToHex
        
        CLR     D6
        JSR     CharToHex_Loop
        RTS
        
CharToHex_Loop

        ADD.B   #%1,    D6  *Update counter
        CMP.W   D1,     D6  *Have we decoded all characters?
        BGT     CharToHex_Done
        MOVE.B  (A1)+,  D2  *Next character
        CMPI.B  #$40,   D2  *Is it a number?
        BLT     CharToHex_Num
        CMPI.B  #$41,   D2  *Is it a letter?
        BGT     CharToHex_Letter
        JMP     error
        
CharToHex_Num

        SUBI.B  #$30,   D2
        BRA     CharToHex_ToLong
        
CharToHex_Letter

        CMPI.B  #$61,   D2  *Is it upper or lower case?
        BGE     LetterIsLower
        BRA     LetterIsUpper
        
LetterIsLower
        SUBI.B  #55,    D2
        BRA     CharToHex_ToLong

LetterIsUpper
        SUBI.B  #87,    D2
        BRA     CharToHex_ToLong
        
CharToHex_ToLong
        LSL.B   #4,     D2
        LSR.B   #4,     D2
        LSL.L   #4,     D4
        ADD.B   D2,     D4
        BRA     CharToHex_Loop
        
CharToHex_Done
        CLR     D1
        CLR     D2
        CLR     D6
        RTS
        
*--Helper: HexToChar--*

Helper_HexToChar
        CLR.B   var_decode_counter
        JMP     HexToChar_Loop

HexToChar_Loop
        ADDI.B  #1, var_decode_counter
        ROL.L   #4, D5
        MOVE.B  D5, D4
        LSL.B   #4, D4
        LSR.B   #4, D4
        JSR     HexToChar_NumOrLetter
        MOVE.B  var_decode_length,  D1
        CMP.B   var_decode_counter, D1
        BNE     HexToChar_Loop
        CLR     D1
        CLR     D4
        CLR     D5
        RTS
        
HexToChar_NumOrLetter
        CMPI.B  #%1010, D4
        BGE     HexToChar_Letter
        BLT     HexToChar_Number
        
HexToChar_Letter
        ADDI.B  #$37,   D4
        MOVE.B  D4,     (A6)+
        RTS

HexToChar_Number
        ADDI.B  #$30,   D4
        MOVE.B  D4,     (A6)+
        RTS
        
        
*--Helper: Buffer Routines--*

Buffer_LoadBuffer
        LEA     var_output_buffer,  A6
        RTS
        
Buffer_ClearBuffer
        CLR     var_output_buffer
        RTS

Buffer_BufferAddress
        JSR     LoadLineAddr
        MOVE.L  var_line_addr,  D5        
        MOVE.B  #8,     var_decode_length
        JSR     Helper_HexToChar
        JSR     Helper_BufferTab
        RTS
        
           

*--Helper: Character Routines--*

Helper_BufferTab
        MOVE.B  #$9,    (A6)+
        RTS

error   NOP *Add: Print error msg
end     NOP

    SIMHALT             ; halt simulator

*---Variables/Constants--*

msg_intro           DC.B    'Welcome to the 68k Dissesembler.',LF,CR,0
msg_start_request   DC.B    'Please enter an starting address: ',0
msg_end_request     DC.B    'Please enter an ending address: ',0
msg_continue_request    DC.B    'Hit any key to continue',0

*--Variables--*

var_start_addr  DS.L    1
var_end_addr    DS.L    1

var_opcode_addr DS.L    1
var_opcode_op   DS.W    1

var_decode_counter  DS.B    1
var_decode_length   DS.B    1

var_num_displayed   DS.W    1

var_line_addr       DS.l    1
var_output_buffer   DS.L    10

    END     START






<<<<<<< HEAD

=======
>>>>>>> b0b42f3c8dd2e1e593c3d4df585a46e546cfe79c
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
