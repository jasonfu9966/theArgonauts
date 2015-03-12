*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
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

        LEA     STACK,  SP
        LEA     JmpTable,   A0

        JSR     Intro
        JSR     GetStartAddr
        JSR     GetEndAddr
        JSR     PrintBlankLine
        JSR     LoadStartAddr
        JSR     MainLoop
        *JMP     GoAgain
        JMP     error
        
*===Main Routines===*

ClearAll
        CLR.B   var_num_displayed
        CLR.L   var_start_addr
        CLR.L   var_end_addr
        RTS
        
ClearAllDn
        CLR.L   D0
        CLR.L   D1
        CLR.L   D2
        CLR.L   D3
        CLR.L   D4
        CLR.L   D5
        CLR.L   D6
        CLR.L   D7
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

code0000        JSR          Group0000      *Immediate Op's: CMPI, SUBI, ANDI, EORI, BCHG
                BRA          DisplayToConsole

code0001       *JSR          Group0001       *MOVE - Byte
*               BRA          continueMain
               
code0010       *JSR          Group0010       *MOVE - Long
*               BRA          continueMain

code0011       *JSR          Group0011       *MOVE - Word
*               BRA          continueMain

code0100       *JSR          code0100Decode *MOVEM + LEA, CLR, JSR, RTS
*               BRA          continueMain

code0101       *JSR          code0101Decode *ADDQ
*               BRA          continueMain

code0110       *JSR          BranchGroup    *Branch Op's: BCC, BGT, BLE, BVS, BRA
*               BRA          continueMain

code0111       *JSR          code0111Decode     *MOVEQ
*               BRA          continueMain

code1000       *JSR          code1000Decode *DIVS,
*               BRA          continueMain

code1001       *JSR          code1001Decode *SUB, SUBA
*               BRA          continueMain

code1010       *JSR          outBadData     *NOT USED
*               BRA          continueMain
 
code1011       *JSR          code1011Decode *EOR, CMP, CMPA,
*               BRA          continueMain

code1100       *JSR          code1100Decode *MULS, AND
*               BRA          continueMain

code1101       *JSR          AddGroup       *ADD, ADDA
*               BRA          continueMain

code1110       *JSR          BitShiftGroup  *Shift/Rotate Op's: LSR, LSL, ASR, ASL, ROR, ROL
*               BRA          continueMain

code1111       *JSR          outBadData     *NOT USED (Not valid for any 68k Op Codes)
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
        JSR     CharToHex
        CLR.L   var_start_addr
        MOVE.L  D4,                 var_start_addr
        CLR     D4
        RTS

GetEndAddr      *Used
        LEA     msg_end_request,    A1
        JSR     Helper_DisplayMsg
        LEA     var_end_addr,       A1
        JSR     Helper_GetInput
        JSR     CharToHex
        CLR.L   var_end_addr
        MOVE.L  D4,                 var_end_addr
        CLR     D4
        RTS

LoadStartAddr
        MOVE.L  var_start_addr, A5
        RTS
        
GoAgain
        LEA     msg_goagain_request,    A1
        JSR     Helper_DisplayMsg
        JSR     Helper_GetAsciiInput
        JSR     PrintBlankLine
        JSR     PrintBlankLine
        CMP.B   #$79,                   D1
        BEQ     GoAgain_Yes
        CMP.B   #$6E,                   D1
        BEQ     GoAgain_No
        JMP     error
        
GoAgain_Yes
        JMP     START
        
GoAgain_No
        JSR     PrintBlankLine
        LEA     msg_thanks,             A1
        JSR     Helper_DisplayMsg
        JMP     END

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
        *JSR     DisplayToConsole
        JSR     UpdateNumDisplayed
        BRA     MainLoop

EndReached
        JMP     GoAgain
        *RTS     *Go Again
        *Yes JMP START
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
        JSR     Helper_GetAsciiInput
        JMP     MainLoop
        
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
        RTS

DisplayToConsole
        JSR     ClearAllDn
        MOVE.B  #$00,               (A6)+
*        CLR.L   D1
*        MOVE.W  var_line_number,    D1
*        MOVE.B  #3,                 D0
*        TRAP    #15
               
        LEA     var_output_buffer,  A1
        MOVE.B  #13,                D0
        TRAP    #15
        JSR     PrintBlankLine
        RTS
        

UpdateNumDisplayed
        ADD.B   #1,     var_num_displayed
        RTS
        
PrintBlankLine
        LEA     msg_blank,          A1
        JSR     Helper_DisplayMsg
        RTS
        
*----------------------------------------------------------------
*              Op Code Decode Routines                          |
*----------------------------------------------------------------

*----------------Group0000

Group0000   *Immediate Op's: CMPI, SUBI, ANDI, EORI, BCHG
        JSR     ClearAllDn
        MOVE.W  var_opcode_op,  D5
        *--Isolate next 4 bits
        *--Isolate size (bit #0 to #2, byte size)
        *--Check if BCHG (bit #3 is set, byte size)
        MOVE.W  D5,     D4
        JSR     Decode_Isolate0to7onD4
        LSR.W   #1,     D4
        BCS     Group0000_BCHG_dn
        BCC     Group0000_cont

Group0000_BCHG_dn
        MOVE.B  #1,     var_opcode_src_mode
        MOVE.B  D4,     var_opcode_src_reg
        JSR     Group0000_BCHG_ea
        BRA     BCHG_Print
        
Group0000_cont
        *--Is it a BCHG?
        CLR     D4
        MOVE.W  D5,     D4
        JSR     Decode_Isolate0to7onD4
        CMP.W   #8,     D4
        BNE     Group0000_IOps_size
        MOVE.B  #0,     var_opcode_src_mode
        JSR     Group0000_BCHG_ea
        BRA     BCHG_Print
   
Group0000_IOps_size
        *--Isolate size (bit #8-#9)
        CLR     D4
        MOVE.B  D5,     D4
        LSR     #6,     D4
        MOVE.B  D4,     var_opcode_size
        JSR     Group0000_IOps_ea
        BRA     Group0000_PrintSwitch

Group0000_BCHG_ea
        *--Isolate BCHG dest mode
        CLR     D4
        MOVE.B  D5,     D4
        LSL.B   #2,     D4
        LSR.B   #5,     D4
        MOVE.B  D4,     var_opcode_dest_mode
        JSR     Group0000_BCHG_SizeCheck
        *--Isolate BCHG dest register
        CLR     D4
        MOVE.B  D5,     D4
        LSL.B   #5,     D4
        LSR.B   #5,     D4
        MOVE.B  D4,     var_opcode_dest_reg
        RTS
        
Group0000_IOps_ea
        *--Isolate EA dest mode
        CLR     D4
        MOVE.B  D5,     D4
        LSL.B   #2,     D4
        LSR.B   #5,     D4
        MOVE.B  D4,     var_opcode_dest_mode
        *--Isolate EA dest register
        CLR     D4
        MOVE.B  D5,     D4
        LSL.B   #5,     D4
        LSR.B   #5,     D4
        MOVE.B  D4,     var_opcode_dest_reg
        RTS
        
Group0000_BCHG_SizeCheck
        CMPI.B  #%00000000, D4
        BEQ     BCHG_IsLong
        BRA     BCHG_IsByte
BCHG_IsLong
        MOVE.B  #%00000010, var_opcode_size
        RTS
BCHG_IsByte
        MOVE.B  #%00000000, var_opcode_size
        RTS

Group0000_PrintSwitch
        CLR     D4
        MOVE.B  D5,     D4
        LSR.W   #8,     D4
        CMPI.W  #%00001100, D4
        BEQ     CMPI_Print
        CMPI.W  #%00000010, D4
        BEQ     ANDI_Print
        CMPI.W  #%00000100, D4
        BEQ     SUBI_Print
        CMPI.W  #%00001010, D4
        BEQ     EORI_Print

        jmp     error
        
*---Group0000 Helpers

Group0000_CheckEAMode
        MOVE.B  var_opcode_src_mode,    D1
        CMPI.B  #0,                     D1
        BEQ     Buffer_GetIDataBySize
        BNE     BufferDataReg

*----------------Group0001
*---todo
Group0001           *Immediate OP code: MOVE.B
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group0010
*---todo
Group0010           *Immediate OP code: MOVE.L
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group0011
*---todo
Group0011               *Immediate OP code: MOVE.W
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group0100
*---todo
code0100Decode          *Immediate OP code: MOVEM, LEA, CLR, JSR, RTS
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group0101
*---todo
code0101Decode          *Immediate OP code: ADDQ
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group0110
*---todo
code0110Decode          *Immediate OP code: BCC, BGT, BLE, BVS, BRA
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group01111
*---todo
code0111Decode          *Immediate OP code: MOVEQ
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group1000
*---todo
code1000Decode           *Immediate OP code: DIVS
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group1001
*---todo
code1001Decode           *Immediate OP code: SUB, SUBA
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group1011
*---todo
code1011Decode           *Immediate OP code: EOR, CMP, CMPA
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group1100
*---todo
code1100Decode           *Immediate OP code: MULS, AND
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group1101
*---todo
AddGroup           *Immediate OP code: ADD, ADDA
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4            

*----------------Group1110
*---todo
BitShiftGroup       *Immediate OP code: LSR, LSL, ASR, ASL, ROR, ROL
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------Group1111
*---todo
outBadData           *No immediate op code
            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            *---Isolate next four bits
            MOVE.W  D5,     D4
            JSR     Decode_Isolate0to7onD4

*----------------------------------------------------------------
*              Op Code Decode Helper Routines                   |
*----------------------------------------------------------------

Decode_Isolate0to7onD4
        LSL.W   #4,         D4
        CLR     D0
        MOVE.W  #SHIFT12,   D0
        LSR.W   D0,         D4
        CLR     D0
        RTS
        
Decode_WordtoHex               ;note: determines hex from first three bits
        MOVE.B   D4, D3
        BSET     #0, D3
        BVS      Bit1XX
        BRA      Bit0XX
        
Bit1XX
        BSET     #1, D3
        BVS      Bit11X
        BRA      Bit10X
        
Bit0XX
        BSET     #1, D3
        BVS      Bit01X
        BRA      Bit00X
        
Bit11X
        BSET     #2, D3
        BVS      Bit111
        BRA      Bit110
        
Bit10X
        BSET     #2, D3
        BVS      Bit101
        BRA      Bit100
        
Bit01X
        BSET     #2, D3
        BVS      Bit011
        BRA      Bit010
        
Bit00X
        BSET     #2, D3
        BVS      Bit001
        BRA      Bit000
        
* Bit000, Bit001, Bit010, Bit011, Bit100, Bit101, Bit110, Bit111
* append the appropriate decimal number to output
;==============================================================================
Bit000
        * append #0
        RTS
        
Bit001
        * append #1
        RTS

Bit010
        * append #2
        RTS

Bit011
        * append #3
        RTS
        
Bit100
        * append #4
        RTS
        
Bit101
        * append #5
        RTS
        
Bit110
        * append #6
        RTS
        
Bit111
        * append #7
        RTS
        
*----------------------------------------------------------------
*              Op Code Decode Print Routines                    |
*----------------------------------------------------------------

BCHG_Print
        JSR     ClearAllDn
        JSR     Buffer_BCHG
        JSR     BufferTab
        JSR     Group0000_CheckEAMode
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn
        JSR     Buffer_CompareMode
        RTS
        
SUBI_Print
        JSR     ClearAllDn
        JSR     Buffer_SUBI
        JSR     Buffer_OpCode_Size
        JSR     Buffer_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn
        JSR     Buffer_CompareMode
        RTS
        
ANDI_Print
        JSR     ClearAllDn
        JSR     Buffer_ANDI
        JSR     Buffer_OpCode_Size
        JSR     Buffer_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn
        JSR     Buffer_CompareMode
        RTS
        
EORI_Print
        JSR     ClearAllDn
        JSR     Buffer_EORI
        JSR     Buffer_OpCode_Size
        JSR     Buffer_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn
        JSR     Buffer_CompareMode
        RTS

CMPI_Print
        JSR     ClearAllDn
        JSR     Buffer_CMPI
        JSR     Buffer_OpCode_Size
        JSR     Buffer_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn
        JSR     Buffer_CompareMode
        RTS


*----------------------------------------------------------------
*              Op Code Name Buffer Routines                     |
*----------------------------------------------------------------

Buffer_BCHG
        MOVE.B      #$42,   (A6)+
        MOVE.B      #$43,   (A6)+
        MOVE.B      #$48,   (A6)+
        MOVE.B      #$47,   (A6)+
        RTS

Buffer_EORI
        JSR         Buffer_EOR
        MOVE.B      #$49,   (A6)+
        RTS

Buffer_EOR
        MOVE.B      #$45,   (A6)+
        MOVE.B      #$4F,   (A6)+
        MOVE.B      #$52,   (A6)+
        RTS
        
Buffer_CMPI
        JSR         Buffer_CMP
        MOVE.B      #$49,   (A6)+
        RTS
        
Buffer_CMP
        MOVE.B      #$43,   (A6)+
        MOVE.B      #$4D,   (A6)+
        MOVE.B      #$50,   (A6)+
        RTS

Buffer_ANDI
        JSR         Buffer_AND
        MOVE.B      #$49,   (A6)+

Buffer_SUBI
        JSR         Buffer_SUB
        MOVE.B      #$49,   (A6)+

Buffer_AND
        MOVE.B      #$41,   (A6)+
        MOVE.B      #$4E,   (A6)+
        MOVE.B      #$44,   (A6)+
        RTS
        
Buffer_SUB
        MOVE.B      #$53,   (A6)+
        MOVE.B      #$55,   (A6)+
        MOVE.B      #$42,   (A6)+
        RTS
        
*----------------------------------------------------------------
*              Op Code Component Buffer Routines                |
*----------------------------------------------------------------

Buffer_OpCode_Size                              ; ?? This displays "ORI"
        MOVE.B      #$4F, (A6)+
        MOVE.B      #$52, (A6)+
        MOVE.B      #$49, (A6)+
        RTS

*----------------------------------------------------------------
*              Op Code Component Buffer Helper Routines         |
*----------------------------------------------------------------

Buffer_GetIDataBySize
        JSR         BufferHash
        MOVE.W      var_opcode_size,    D1
        CMPI.B      #0,                 D1
        BEQ         Buffer_GetByte
        CMPI.B      #1,                 D1
        BEQ         Buffer_GetWord
        CMPI.B      #2,                 D1
        BEQ         Buffer_GetLong
        RTS
        
*----------------------------------------------------------------
*              EA Component Buffer Helper Routines              |
*----------------------------------------------------------------

Buffer_GetByte
        JSR         BufferDollar
        MOVE.W      (A5)+,              D5
        MOVE.B      #2,                 var_decode_length
        CLR.B       var_decode_counter
        MOVE.B      #24,                D4
        LSL.L       D4,                 D5
        JSR         HexToChar
        RTS

Buffer_GetWord
        JSR         BufferDollar
        MOVE.W      (A5)+,              D5
        MOVE.B      #4,                 var_decode_length
        CLR.B       var_decode_counter
        MOVE.B      #16,                D4
        LSL.L       D4,                 D5
        JSR         HexToChar
        RTS
        
Buffer_GetLong
        JSR         BufferDollar
        MOVE.L      (A5)+,              D5
        MOVE.B      #8,                 var_decode_length
        CLR.B       var_decode_counter
        JSR         HexToChar
        RTS

*--Mode Comparision Routines--*

Buffer_CompareMode     
        CMPI.B  #%000,          D2      *last three are zeroes
        BEQ     Buffer_Mode_DataReg     *jump to subroutine for Data register Source
        BNE     ModeCompare1

ModeCompare1
        CMPI.B  #%001,          D2
        BEQ     Buffer_Mode_AddrReg
        BNE     ModeCompare2

ModeCompare2
        CMPI.B  #%010,          D2
        BEQ     Buffer_Mode_AddrIndr
        BNE     ModeCompare3

ModeCompare3
        CMPI.B  #%011,          D2
        BEQ     Buffer_Mode_AddrPost
        BNE     ModeCompare4

ModeCompare4
        CMPI.B  #%100,          D2
        BEQ     Buffer_Mode_AddrPre
        BNE     ModeCompare7
                
ModeCompare7
        CMPI.B  #%111,          D2
        BEQ     Buffer_CompareXn
        BNE     error

*--Xn Comparision Routines--*

Buffer_CompareXn
        CMPI.B  #%000,          D3
        BEQ     Buffer_GetWord
        BNE     XnCompare1

XnCompare1
        CMPI.B  #%001,          D3
        BEQ     Buffer_GetLong
        BNE     XnCompare5
        
XnCompare5
        CMPI.B  #100,           D3
        BEQ     Buffer_GetImmediate
        BNE     error
        
*--Immediate Data--*

Buffer_GetImmediate
        JSR     BufferHash
        CMPI.B  #4,             var_opcode_typeid
        BLT     ImmediateData_TypeMove
        
        CMPI.B  #1,             var_opcode_sizebits
        BEQ     ImmediateData_TypeSize1
        
        CMPI.B  #2,             var_opcode_sizebits
        BEQ     ImmediateData_TypeSize2
        BRA     error
        
ImmediateData_TypeMove
        MOVE.W  var_opcode_size,    D4
        CMPI.B  #%01,               D4
        BEQ     Buffer_GetByte
        CMPI.B  #%11,               D4
        BEQ     Buffer_GetWord
        CMPI.B  #%10,               D4
        BEQ     Buffer_GetLong
        BRA     error
        
ImmediateData_TypeSize1
        MOVE.W  var_opcode_size,    D4
        CMPI.B  #%0,                D4
        BEQ     Buffer_GetWord
        CMPI.B  #%1,                D4
        BEQ     Buffer_GetLong
        BRA     error
        
ImmediateData_TypeSize2
        MOVE.W  var_opcode_size,    D4
        CMPI.B  #%00,               D4
        BEQ     Buffer_GetByte
        CMPI.B  #%10,               D4
        BEQ     Buffer_GetWord
        CMPI.B  #%11,               D4
        BEQ     Buffer_GetLong
        BRA     error
        
*----------------------------------------------------------------
*              Buffer Load Routines                             |
*----------------------------------------------------------------

*==Mode Loads==*

*--Data Reg--*

Buffer_Mode_DataReg
        JSR     BufferDataReg
        JSR     HexToChar_NumOrLetter
        RTS     

Buffer_Mode_AddrReg
        JSR     BufferAddrReg
        JSR     HexToChar_NumOrLetter
        RTS

Buffer_Mode_AddrIndr
        JSR     BufferParenLeft
        JSR     BufferAddrReg
        JSR     HexToChar_NumOrLetter
        JSR     BufferParenRight
        RTS

Buffer_Mode_AddrPost
        JSR     BufferParenLeft
        JSR     BufferAddrReg
        JSR     HexToChar_NumOrLetter
        JSR     BufferParenRight
        JSR     BufferSignPlus
        RTS

Buffer_Mode_AddrPre
        JSR     BufferSignMinus
        JSR     BufferParenLeft
        JSR     BufferAddrReg
        JSR     HexToChar_NumOrLetter
        JSR     BufferParenRight
        RTS


*----------------------------------------------------------------
*              Global Buffer Helper Routines                    |
*----------------------------------------------------------------

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
        
Helper_GetAsciiInput

        MOVE.B  #5,     D0
        TRAP    #15
        CLR     D0
        RTS

*--Helper: CharToHex--*

CharToHex
        
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

HexToChar
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
        JSR     HexToChar
        JSR     BufferTab
        RTS

*----------------------------------------------------------------
*              Buffer Ascii Load Routines                       |
*----------------------------------------------------------------

*--Modes--*

BufferDataReg
        MOVE.B  #$44,   (A6)+
        RTS
        
BufferAddrReg
        MOVE.B  #$41,   (A6)+
        RTS

*--Character Routines--*

BufferTab
        MOVE.B  #$9,    (A6)+
        RTS
        
BufferHash
        MOVE.B  #$23,   (A6)+
        RTS
        
BufferDollar
        MOVE.B  #$24,   (A6)+
        RTS
        
BufferComma
        MOVE.B  #$2C,   (A6)+
        RTS

BufferSpace
        MOVE.B  #$20,   (A6)+
        RTS
        
BufferParenLeft
        MOVE.B  #$41,   (A6)+
        RTS

BufferParenRight
        MOVE.B  #$29,   (A6)+
        RTS

BufferSignPlus
        MOVE.B  #$2B,   (A6)+
        RTS

BufferSignMinus
        MOVE.B  #$2D,   (A6)+
        RTS

*----------------------------------------------------------------
*              End and Error                                    |
*----------------------------------------------------------------

error   NOP *Add: Print error msg
end     NOP

    SIMHALT             ; halt simulator

*----------------------------------------------------------------
*              Variables and Constants                          |
*----------------------------------------------------------------

*---Variables/Constants--*

msg_intro           DC.B    'Welcome to the 68k Disassembler.',0
msg_start_request   DC.B    'Please enter an starting address: ',0
msg_end_request     DC.B    'Please enter an ending address: ',0
msg_continue_request    DC.B    'Hit any key to continue...',0
msg_goagain_request     DC.B    'Would you like to dissassemble a new location?',CR,LF
                        DC.B    'Type (y)es or (n)o and hit "Enter"',0
msg_thanks              DC.B    'Thanks for using the TeamReliable Disassembler!',CR,LF
                        DC.B    'Please give us money. ',0
msg_blank               DC.B    '',0

*--Variables--*

var_start_addr  DS.L    1
var_end_addr    DS.L    1

var_opcode_typeid   DS.W    1

var_opcode_addr         DS.L    1
var_opcode_op           DS.W    1
var_opcode_sizebits     DS.W    1
var_opcode_size         DS.B    1
var_opcode_src_mode     DS.B    1
var_opcode_src_reg      DS.B    1
var_opcode_dest_mode    DS.B    1
var_opcode_dest_reg     DS.B    1

var_decode_counter  DS.B    1
var_decode_length   DS.B    1

var_num_displayed   DS.W    1

var_line_addr       DS.L    1
var_line_number     DS.W    1
var_output_buffer   DS.L    10

    END     START














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
