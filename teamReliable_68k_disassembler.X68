*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*----------------------------------------------------------

*--Preprocessor Instructions--*

LF      EQU     $0A *New Line (Line Feed)
CR      EQU     $0D *Carriage Return

*--Code Body--*

        ORG    $1000
    
START   JSR     LoadStackJump
        JSR     Intro
        JSR     GetStartAddr
        JSR     GetEndAddr
        JMP     End
        
*--Main Routines--*

Intro
        LEA     msg_intro, A1
        JSR     Helper_DisplayMsg
        RTS

GetStartAddr

        LEA     msg_start_request,  A1
        JSR     Helper_DisplayMsg
        LEA     var_start_addr,  A1
        CLR     D0
        JSR     Helper_GetInput
        JSR     Helper_CharToHex
        RTS

GetEndAddr

        LEA     msg_end_request,  A1
        JSR     Helper_DisplayMsg
        LEA     var_end_addr,  A1
        CLR     D0
        JSR     Helper_GetInput
        JSR     Helper_CharToHex
        RTS
        
*--Helper Routines--*

Helper_DisplayMsg

        MOVE.B  #13,    D0
        TRAP    #15
        RTS
        
Helper_GetInput

        MOVE.B  #2,     D0
        TRAP    #15
        RTS
        
Helper_CharToHex
        
        CLR     D6
        JSR     CharToHex
        RTS
        
CharToHex

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
        BRA     CharToHex
        
CharToHex_Done
        RTS
        

error   NOP *Add: Print error msg        
        
end     NOP

    SIMHALT             ; halt simulator

*---Variables/Constants--*

msg_intro           DC.B    'Welcome to the 68k Dissesembler.',LF,CR,0
msg_start_request   DC.B    'Please enter an starting address: ',0
msg_end_request     DC.B    'Please enter an ending address: ',0

*--Variables--*

var_start_addr  DS.L    1
var_end_addr    DS.L    1

    END     START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
