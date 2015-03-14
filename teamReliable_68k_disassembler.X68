*-----------------------------------------------------------
* Title      :      Easy68k Disassembler
* Written by :      Nicholas Abel and Jason Fu
* Date       :      March 2015
* Description:      Documentation
*----------------------------------------------------------

*===Preprocessor Instructions===*

LF      EQU     $0A *New Line (Line Feed)
CR      EQU     $0D *Carriage Return

STACK   EQU     $A000

SHIFT9  EQU     9
SHIFT10 EQU     10
SHIFT11 EQU     11
SHIFT12 EQU     12
SHIFT13 EQU     13
SHIFT14 EQU     14
SHIFT15 EQU     15
SHIFT16 EQU     16
SHIFT24 EQU     24

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
        JMP     MainLoop
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

code0000        JSR             Group0000       *Immediate Op's: CMPI, SUBI, ANDI, EORI, BCHG
                BRA             DisplayToConsole

code0001        JSR             Group0001       *MOVE - Byte
                BRA             DisplayToConsole
               
code0010        JSR             Group0010       *MOVE - Long
                BRA             DisplayToConsole

code0011        JSR             Group0011       *MOVE - Word
                BRA             DisplayToConsole

code0100        JSR             Group0100       *MOVEM + LEA, CLR, JSR, RTS
                BRA             DisplayToConsole

code0101        JSR             Group0101        *ADDQ
                BRA             DisplayToConsole

code0110        JSR             Group0110        *Branch Op's: BCC, BGT, BLE, BVS, BRA
                BRA             DisplayToConsole

code0111        JSR             Group0111        *MOVEQ
                BRA             DisplayToConsole

code1000        JSR             Group1000        *DIVS,
                BRA             DisplayToConsole

code1001        JSR             Group1001        *SUB, SUBA
                BRA             DisplayToConsole

code1010        JSR             Group1010        *NOT USED
                BRA             DisplayToConsole
 
code1011        JSR             Group1011        *EOR, CMP, CMPA,
                BRA             DisplayToConsole

code1100        JSR             Group1100        *MULS, AND
                BRA             DisplayToConsole

code1101        JSR             Group1101        *ADD, ADDA
                BRA             DisplayToConsole

code1110        JSR             Group1110        *Shift/Rotate Op's: LSR, LSL, ASR, ASL, ROR, ROL
                BRA             DisplayToConsole

code1111        JSR             Group1111        *NOT USED (Not valid for any 68k Op Codes)
                BRA             DisplayToConsole

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
        JSR     UpdateNumDisplayed
        JMP     MainLoop

EndReached
        JMP     GoAgain
        
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
        RTS
        
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
*        JSR     PrintBlankLine
        RTS
        

UpdateNumDisplayed
        ADD.B   #1,     var_num_displayed
        RTS
        
PrintBlankLine
        LEA     msg_blank,          A1
        JSR     Helper_DisplayMsg
        RTS
        
*----------------------------------------------------------------
*              Opcode Main Routines                             |
*----------------------------------------------------------------


*Group0000 
*Immediate Op's: CMPI, SUBI, ANDI, EORI, BCHG
*================================================================

Group0000
        JSR     ClearAllDn
        MOVE.W  #0,             var_opcode_typeid
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

        BRA     BCHG_Decode
        
Group0000_cont
        *--Is it a BCHG?
        CLR     D4
        MOVE.W  D5,     D4
        JSR     Decode_Isolate0to7onD4
        CMP.W   #8,     D4
        BNE     Group0000_IOps_size
        MOVE.B  #0,     var_opcode_src_mode
        JSR     Group0000_BCHG_ea

        BRA     BCHG_Decode
   
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
        BEQ     CMPI_Decode
        CMPI.W  #%00000010, D4
        BEQ     ANDI_Decode
        CMPI.W  #%00000100, D4
        BEQ     SUBI_Decode
        CMPI.W  #%00001010, D4
        BEQ     EORI_Decode

        jmp     error
        
*---Group0000 Helpers

Group0000_CheckEAMode
        MOVE.B  var_opcode_src_mode,    D1
        CMPI.B  #0,                     D1
        BEQ     Decode_GetIDataBySize
        BNE     Group0000_Buffer_Src_Reg_Prep
        
Group0000_Buffer_Src_Reg_Prep
        JSR     Buffer_PrepareSrcReg_OnD3
        JMP     Buffer_Mode_DataReg


*Group0001 
*Immediate OP code: MOVE.B
*================================================================

Group0001
        JSR     ClearAllDn
        MOVE.B  #1,     var_opcode_typeid
        MOVE.B  #1,     var_opcode_size
        JSR     Buffer_MOVE
        JSR     BufferSizeByte
        JSR     Decode_Move_src
        JSR     BufferComma
        JSR     BufferSpace
        JSR     Decode_Move_dest
        RTS

*Group0010 
*Immediate OP code: MOVE.L
*================================================================

Group0010
        JSR     ClearAllDn
        MOVE.B  #2,     var_opcode_typeid
        MOVE.B  #3,     var_opcode_size
        JSR     Buffer_MOVE
        JSR     BufferSizeLong
        JSR     Decode_Move_src
        JSR     BufferComma
        JSR     BufferSpace
        JSR     Decode_Move_dest
        RTS

*Group0011 
*Immediate OP code: MOVE.W
*================================================================

Group0011
        JSR     ClearAllDn
        MOVE.B  #3,     var_opcode_typeid
        MOVE.B  #2,     var_opcode_size
        JSR     Buffer_MOVE
        JSR     BufferSizeWord
        JSR     Decode_Move_src
        JSR     BufferComma
        JSR     BufferSpace
        JSR     Decode_Move_dest
        RTS

*Group0100 
*Immediate OP code: MOVEM, LEA, CLR, JSR, RTS
*================================================================

Group0100
        JSR     ClearAllDn
        MOVE.B  #4,             var_opcode_typeid
        MOVE.W  var_opcode_op,  D5
        MOVE.W  D5,             D4
        LSL.W   #4,             D4
        MOVE.W  #SHIFT12,       D3
        LSR.W   D3,             D4
        MOVE.B  D4,             var_group0100_id
        
        MOVE.W  D5,             D4
        LSL.W   #7,             D4
        MOVE.W  #SHIFT13,       D3
        LSR.W   D3,             D4
        MOVE.W  D4,             var_group0100_id_LEA       
        
        MOVE.W  D5,             D4
        LSL.W   #8,             D4
        MOVE.W  #SHIFT14,       D3
        LSR.W   D3,             D4
        MOVE.B  D4,             var_opcode_size        
        
        MOVE.W  D5,             D4
        LSL.W   #4,             D4

        MOVE.W  #SHIFT13,       D3
        LSR.W   D3,             D4
        MOVE.B  D4,             var_opcode_dest_reg

        MOVE.W  D5,             D4
        MOVE.W  #SHIFT10,       D3
        LSL.W   D3,             D4
        MOVE.W  #SHIFT13,       D3
        LSR.W   D3,             D4
        MOVE.W  D4,             var_opcode_src_mode
                
        MOVE.W  D5,             D4
        MOVE.W  #SHIFT13,       D3
        LSL.W   D3,             D4
        LSR.W   D3,             D4
        MOVE.W  D4,             var_opcode_src_reg
        
        CMPI.W  #%111,          var_group0100_id_LEA
        BEQ     LEA_Decode
        CMPI.W  #%0010,         var_group0100_id
        BEQ     CLR_Decode
        CMPI.W  #%1100,         var_group0100_id
        BEQ     MOVEM_Decode_MemToReg
        CMPI.W  #%1000,         var_group0100_id
        BEQ     MOVEM_Decode_RegToMem
        CMPI.W  #%1110,         var_group0100_id
        BEQ     Group0100_CheckJSROrRTS
        
        JMP     error
        
Group0100_CheckJSROrRTS
        CMPI.W  #%10,           var_opcode_size
        BEQ     JSR_Decode
        CMPI.W  #01,            var_opcode_size
        BEQ     RTS_Decode
        BNE     error
        
        
*            JSR     ClearAllDn
*            MOVE.W  var_opcode_op,  D5
*            *---Isolate next four bits
*            MOVE.W  D5,     D4
*            JSR     Decode_Isolate0to7onD4


*Group0101
*Immediate OP code: ADDQ
*================================================================

Group0101
        JSR     ClearAllDn
        MOVE.B  #5,             var_opcode_typeid
        MOVE.W  var_opcode_op,  D5
        JSR     Isolate_size
        MOVE.B  var_temp,       var_opcode_size
        JSR     Isolate_Bits10to12totemp         ;EA Mode
        MOVE.B  var_temp,       var_opcode_src_mode
        JSR     Isolate_Bits13to15totemp         ;EA Register
        MOVE.B  var_temp,       var_opcode_src_reg
        JSR     Isolate_Bits4to6totemp           ;data (0-7)
        MOVE.B  var_temp,       var_opcode_dest_reg
        JSR                     ADDQ_DECODE
        RTS

*Group0110
*Immediate OP code: BCC, BGT, BLE, BVS, BRA
*================================================================

Group0110
        JSR     ClearAllDn
        MOVE.W  var_opcode_op,  D5
        
        CLR.B   var_group0110_condition
        MOVE.W  D5,             D4
        LSL.W   #4,             D4
        MOVE.W  #SHIFT12,       D3
        LSR.W   D3,             D4
        MOVE.B  D4,             var_group0110_condition
        CLR     D4
        
        CLR.B   var_group0110_displacement
        MOVE.W  D5,             D4
        LSL.W   #8,             D4
        LSR.W   #8,             D4
        MOVE.B  D4,             var_group0110_displacement
        
        JSR     Bcc_Decode
        RTS
            


*Group0111
*Immediate OP code: MOVEQ
*================================================================

Group0111

*            JSR     ClearAllDn
*            MOVE.W  var_opcode_op,  D5
*            *---Isolate next four bits
*            MOVE.W  D5,     D4
*            JSR     Decode_Isolate0to7onD4

*----------------Group1000

Group1000           *Immediate OP code: DIVS

            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            JSR     Isolate_Bits4to6totemp          ; DEST REG
            MOVE.B  var_temp,       var_opcode_dest_reg
            JSR     Isolate_Bits10to12totemp        ;EA Mode
            MOVE.B  var_temp,       var_opcode_src_mode
            JSR     Isolate_Bits13to15totemp        ;EA Register
            MOVE.B  var_temp,       var_opcode_src_reg
            JSR     DIVS_Decode
            RTS


*----------------Group1001

Group1001           *Immediate OP code: SUB, SUBA

*            JSR     ClearAllDn
*            MOVE.W  var_opcode_op,  D5
*            *---Isolate next four bits
*            MOVE.W  D5,     D4
*            JSR     Decode_Isolate0to7onD4

*----------------Group1010

Group1010

*----------------Group1011

Group1011           *Immediate OP code: EOR, CMP, CMPA

*            JSR     ClearAllDn
*            MOVE.W  var_opcode_op,  D5
*            *---Isolate next four bits
*            MOVE.W  D5,     D4
*            JSR     Decode_Isolate0to7onD4

*----------------Group1100

Group1100           *Immediate OP code: MULS, AND

*            JSR     ClearAllDn
*            MOVE.W  var_opcode_op,  D5
*            *---Isolate next four bits
*            MOVE.W  D5,     D4
*            JSR     Decode_Isolate0to7onD4

*----------------Group1101

Group1101           *Immediate OP code: ADD, ADDA

*            JSR     ClearAllDn
*            MOVE.W  var_opcode_op,  D5
*            *---Isolate next four bits
*            MOVE.W  D5,     D4
*            JSR     Decode_Isolate0to7onD4            

*----------------Group1110

Group1110       *Immediate OP code: LSR, LSL, ASR, ASL, ROR, ROL

            JSR     ClearAllDn
            MOVE.W  var_opcode_op,  D5
            
            JSR     Isolate_Direction
            MOVE.B  var_temp,       var_opcode_direction
            
            JSR     Isolate_Size
            MOVE.B  var_temp,       var_opcode_size
            
            CLR.W   D4
            MOVE.W  D5,             D4
            LSL.B   #2,             D4
            LSR.B   #7,             D4
            MOVE.B  D4,             var_group1110_imme_or_reg
            
            CLR.W   D4
            MOVE.W  D5,             D4
            LSL.W   #4,             D4
            MOVE.B  #SHIFT13,       D3
            LSR.W   D3,             D4
            MOVE.B  D4,             var_group1110_count_or_reg
            
            CLR     D4
            MOVE.W  D5,             D4
            MOVE.W  #SHIFT10,       D3
            LSL.W   D3,             D4
            MOVE.W  #SHIFT13,       D3
            LSR.W   D3,             D4
            MOVE.B  D4,             var_opcode_dest_mode
            
            CLR     D4
            MOVE.W  D5,             D4
            MOVE.W  #SHIFT13,       D3
            LSL.W   D3,             D4
            LSR.W   D3,             D4
            MOVE.B  D4,             var_opcode_dest_reg
            
            CLR     D4
            MOVE.W  D5,             D4
            LSR.W   #3,             D4
            MOVE.W  #SHIFT14,       D3
            LSL.W   D3,             D4
            LSR.W   D3,             D4
            CLR.B   var_group1110_shift_or_rotate
            MOVE.B  D4,             var_group1110_shift_or_rotate
            JMP     Group1110_TypeCheck
            
Group1110_TypeCheck
            CLR     D4
            MOVE.B  var_group1110_shift_or_rotate,  D4
            CMPI.B  #%01,           D4
            BEQ     LSd_Decode
            CMPI.B  #%00,           D4
            BEQ     ASd_Decode
            CMPI.B  #%11,           D4
            BEQ     ROd_Decode
            BNE     error

*----------------Group1111

Group1111           *No immediate op code

*            JSR     ClearAllDn
*            MOVE.W  var_opcode_op,  D5
*            *---Isolate next four bits
*            MOVE.W  D5,     D4
*            JSR     Decode_Isolate0to7onD4

*----------------------------------------------------------------
*              Bit Isolation Routines                           |
*----------------------------------------------------------------

Decode_Isolate0to7onD4
        LSL.W   #4,         D4
        CLR     D0
        MOVE.W  #SHIFT12,   D0
        LSR.W   D0,         D4
        CLR     D0
        RTS
        
*Decode_Move_Src_Reg                         *isolates bits 13-15
Isolate_Bits4to6totemp                        *isolates bits 4to6
        CLR     D3
        CLR     D4
        CLR     D5
        CLR.B   var_temp
        MOVE.W  var_opcode_op,  D5
        MOVE.W  D5,             D4
        MOVE.B  #SHIFT12,       D3
        ROR.W   D3,             D4
        MOVE.B  #SHIFT13,       D3 
        LSR.W   D3,             D4
        MOVE.B  D4,             var_temp
        RTS

Isolate_Bits7to9totemp                       *isolates bits 7to9
        CLR     D3
        CLR     D4
        CLR     D5
        CLR.B   var_temp
        MOVE.W  var_opcode_op,  D5
        MOVE.W  D5,             D4
        LSL.W   #7,             D4
        MOVE.B  #SHIFT13,       D3
        LSR.W   D3,             D4
*        MOVE.B  #SHIFT12,       D3
*        ROR.W   D3,             D4
*        MOVE.B  #SHIFT10,       D3
*        LSR.W   D3,             D4
*        ROR.W   #3,             D0
*        MOVE.B  #SHIFT13,       D3
*        LSR.W   D3,             D4
        MOVE.B  D4,             var_temp
        RTS

Isolate_Bits10to12totemp                        *isolates bits 10to12
        CLR     D3
        CLR     D4
        CLR     D5
        CLR.B   var_temp
        MOVE.W  var_opcode_op,  D5
        MOVE.W  D5,             D4
        ROR.W   #6,             D4
        MOVE.B  #SHIFT13,       D3
        LSR.W   D3,             D4
        MOVE.B  D4,             var_temp
        RTS

Isolate_Bits13to15totemp                         *isolates bits 13to15
        CLR     D3
        CLR     D4
        CLR     D5
        CLR.B   var_temp
        MOVE.W  var_opcode_op,  D5
        MOVE.W  D5,             D4
        ROR.W   #3,             D4
        MOVE.B  #SHIFT13,       D3
        LSR.W   D3,             D4
        MOVE.B  D4,             var_temp 
        RTS

Decode_Move_Buffer_Src        
        CLR     D2
        CLR     D3
        CLR     D4
        MOVE.B  var_opcode_src_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_src_reg,    D3  *used in CompareXn
        JSR     Decode_CompareMode
        RTS
        
Decode_Move_Buffer_Dest
        CLR     D2
        CLR     D3
        CLR     D4
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn
        JSR     Decode_CompareMode
        RTS

Decode_Move_Src
        JSR     Isolate_Bits13to15totemp
        MOVE.B  var_temp,       var_opcode_src_reg
        JSR     Isolate_Bits10to12totemp
        MOVE.B  var_temp,       var_opcode_src_mode
        JSR     Decode_Move_Buffer_Src
        RTS

Decode_Move_Dest
        JSR     Isolate_Bits4to6totemp
        MOVE.B  var_temp,       var_opcode_dest_reg
        JSR     Isolate_Bits7to9totemp
        MOVE.B  var_temp,       var_opcode_dest_mode
        JSR     Decode_Move_Buffer_Dest
        RTS

;       for use in ADD, ADDQ, SUB, SUBI, CLR, AND, ANDI, EOR, EORI, CMP, CMPI
*Isolate_Size                                *isolates bits 9 and 10 
*        CLR     D4
*        MOVE.W  D5,             D4
*        ROR.W   #7,             D4
*        MOVE.B  #SHIFT14,       D3
*        LSR.W   D3,             D4
*
*        MOVE.B  D4,             var_temp
*        RTS
        
Isolate_Size
        CLR     D4
        MOVE.W  D5,             D4
        ROR.W   #8,             D4
        MOVE.B  #SHIFT14,       D3
        LSR.W   D3,             D4
        MOVE.B  D4,             var_temp
        RTS
        
Isolate_Direction
        CLR     D4
        MOVE.W  D5,             D4
        MOVE.B  #SHIFT9,        D3
        ROR.W   D3,             D4
        MOVE.B  #SHIFT15,       D3
        LSR.W   D3,             D4
        MOVE.B  D4,             var_temp
        RTS

*----------------------------------------------------------------
*              OpCode Decode Routines                           |
*----------------------------------------------------------------


BCHG_Decode
        JSR     ClearAllDn
        JSR     Buffer_BCHG
        JSR     BufferTab
        JSR     Group0000_CheckEAMode
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn

        JSR     Decode_CompareMode
        RTS
        

SUBI_Decode
        JSR     ClearAllDn
        JSR     Buffer_SUBI

        JSR     Decode_OpCode_Size
        JSR     Decode_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn

        JSR     Decode_CompareMode
        RTS
        

ANDI_Decode
        JSR     ClearAllDn
        JSR     Buffer_ANDI

        JSR     Decode_OpCode_Size
        JSR     Decode_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn

        JSR     Decode_CompareMode
        RTS
        

EORI_Decode
        JSR     ClearAllDn
        JSR     Buffer_EORI

        JSR     Decode_OpCode_Size
        JSR     Decode_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn

        JSR     Decode_CompareMode
        RTS


CMPI_Decode
        JSR     ClearAllDn
        JSR     Buffer_CMPI

        JSR     Decode_OpCode_Size
        JSR     Decode_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn
        JSR     Decode_CompareMode
        RTS

LEA_Decode
        JSR     ClearAllDn
        JSR     Buffer_LEA
        JSR     BufferTab
        JSR     BufferSpace
        MOVE.B  var_opcode_src_mode,    D2
        MOVE.B  var_opcode_src_reg,     D3
        JSR     Decode_CompareMode
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_group0100_id,       D3
        MOVE.B  #%001,                  var_opcode_dest_mode
        MOVE.B  var_opcode_dest_mode,   D2
        JSR     Decode_CompareMode
        RTS

CLR_Decode
        JSR     Buffer_CLR
        JSR     Decode_OpCode_Size
        JSR     BufferTab
        JSR     BufferSpace
        MOVE.B  var_opcode_src_mode,    D2
        MOVE.B  var_opcode_src_reg,     D3
        JSR     Decode_CompareMode
        RTS

MOVEM_Decode
        JSR     Buffer_MOVEM
        JSR     Buffer_OpCode_Size_Group0000
        RTS

MOVEM_Decode_RegToMem
        JSR     MOVEM_Decode
        JSR     Buffer_GetWord
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_src_mode,    D2
        MOVE.B  var_opcode_src_reg,     D3
        JSR     Decode_CompareMode
        RTS

MOVEM_Decode_MemToReg
        JSR     MOVEM_Decode
        CMPI.W  #%111,                  var_opcode_src_mode
        BEQ     MOVEM_Decode_Get_Word
        MOVE.B  var_opcode_src_mode,    D2
        MOVE.B  var_opcode_src_reg,     D3
        JSR     Decode_CompareMode
        JSR     BufferComma
        JSR     BufferSpace
        JSR     Buffer_GetWord
        RTS

MOVEM_Decode_Get_Word
        JSR     Decode_StoreData_Word
        JMP     MOVEM_Decode_Buffer_Data

MOVEM_Decode_Get_Long
        JSR     Decode_StoreData_Word
        JMP     MOVEM_Decode_Buffer_Data
        
MOVEM_Decode_Buffer_Data
        MOVE.B  #1,                     var_decode_buffer_data_flag
        MOVE.B  var_opcode_src_mode,    D2
        MOVE.B  var_opcode_src_reg,     D3
        JSR     Decode_CompareMode
        JSR     BufferComma
        JSR     BufferSpace
        JSR     BufferDollar
        CLR     D4
        MOVE.L  var_opcode_data,        D4
        CLR.B   var_decode_length
        MOVE.B  #4,                     var_decode_length
        JSR     HexToChar

JSR_Decode
        JSR     Buffer_JSR
        JSR     BufferTab
        JSR     BufferSpace
        MOVE.B  var_opcode_src_reg,     D2
        MOVE.B  var_opcode_src_mode,    D3
        JSR     Decode_CompareMode
        RTS

RTS_Decode
        JSR     Buffer_RTS
        RTS

ADDQ_Decode                             ;figure out about printing immediate data
        JSR     ClearAllDn
        JSR     Buffer_ADDQ

        JSR     Decode_OpCode_Size
        JSR     BufferHash
        JSR     BufferDollar
        JSR     Decode_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2  *used in CompareMode        
        MOVE.B  var_opcode_dest_reg,    D3  *used in CompareXn

        JSR     Decode_CompareMode
        RTS

DIVS_Decode                             ;figure out about printing immediate data
        JSR     ClearAllDn
        JSR     Buffer_DIVS
        
        JSR     Decode_GetIDataBySize
        JSR     BufferComma
        JSR     BufferSpace
        MOVE.B  var_opcode_dest_mode,   D2
        MOVE.B  var_opcode_dest_reg,    D3
        
        JSR     Decode_CompareMode
        RTS

LSd_Decode
        JSR     Buffer_LSd
        JSR     LS_AS_RO_Decode
        RTS

ASd_Decode
        JSR     Buffer_ASd
        JSR     LS_AS_RO_Decode
        RTS
        
ROd_Decode
        JSR     Buffer_ROd
        JSR     LS_AS_RO_Decode
        RTS

LS_AS_RO_Decode
        JSR     Decode_Opcode_Direction
        JSR     Decode_Opcode_Size
        JSR     Decode_Shift_Mid
        JSR     BufferComma
        JSR     BufferSpace
        JSR     Decode_Shift_End
        RTS
        
Bcc_Decode
        JSR     Bcc_Decode_Type
        JSR     BufferSpace
        JSR     Bcc_Decode_Displacement
        RTS
        
Bcc_Decode_Type
        CLR     D4
        MOVE.B  var_group0110_condition,    D4
        CMPI.B  #%0000,                     D4
        BEQ     Buffer_BRA
        CMPI.B  #%0010,                     D4
        BEQ     Buffer_BHI
        CMPI.B  #%0110,                     D4
        BEQ     Buffer_BNE
        CMPI.B  #%0111,                     D4
        BEQ     Buffer_BEQ
        CMPI.B  #%1101,                     D4
        BEQ     Buffer_BLT
        JMP     error
        
Bcc_Decode_Displacement
        CLR     D4
        JSR     BufferTab
        MOVE.B  var_group0110_displacement, D4
        CMPI.B  #$FF,                       D4
        BEQ     Bcc_Get_Displacement_Long
        CMPI.B  #$00,                       D4
        BEQ     Bcc_Get_Displacement_Word
        BRA     Bcc_Get_Displacement_Byte
        
Bcc_Get_Displacement_Long
        JSR     Buffer_GetLong
        RTS

Bcc_Get_Displacement_Word
        JSR     Buffer_GetWord
        RTS

Bcc_Get_Displacement_Byte
        JSR     Buffer_GetByte
        RTS

*----------------------------------------------------------------
*              Opcode Buffer Routines                           |
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

Buffer_MOVE
        MOVE.B      #$4D, (A6)+
        MOVE.B      #$4F, (A6)+
        MOVE.B      #$56, (A6)+
        MOVE.B      #$45, (A6)+
        RTS
        
Buffer_MOVEM
        JSR         Buffer_MOVE
        MOVE.B      #$4D,   (A6)+
        RTS

Buffer_MOVEQ
        JSR         Buffer_MOVE
        MOVE.B      #$41,   (A6)+
        RTS

Buffer_ADD
        MOVE.B      #$41,    (A6)+
        MOVE.B      #$44,    (A6)+
        MOVE.B      #$44,    (A6)+
        RTS

Buffer_ADDA
        JSR         Buffer_ADD
        MOVE.B      #$41,    (A6)+
        RTS

Buffer_ADDQ
        JSR         Buffer_ADD
        MOVE.B      #$51,     (A6)+
        RTS

Buffer_DIVS
        MOVE.B      #$44,   (A6)+
        MOVE.B      #$49,   (A6)+
        MOVE.B      #$56,   (A6)+
        MOVE.B      #$53,   (A6)+
        RTS
        
Buffer_LEA
        MOVE.B      #$4C,   (A6)+
        MOVE.B      #$45,   (A6)+
        MOVE.B      #$41,   (A6)+
        RTS
        
Buffer_CLR
        MOVE.B      #$43,   (A6)+
        MOVE.B      #$4C,   (A6)+
        MOVE.B      #$52,   (A6)+
        RTS
        
Buffer_JSR
        MOVE.B      #$4A,   (A6)+
        MOVE.B      #$53,   (A6)+
        MOVE.B      #$52,   (A6)+
        RTS
        
Buffer_RTS
        MOVE.B      #$52,   (A6)+
        MOVE.B      #$54,   (A6)+
        MOVE.B      #$53,   (A6)+
        RTS
        
Buffer_LSd
        MOVE.B      #$4C,   (A6)+
        MOVE.B      #$53,   (A6)+
        RTS
        
Buffer_ASd
        MOVE.B      #$41,   (A6)+
        MOVE.B      #$53,   (A6)+
        RTS
        
Buffer_ROd
        MOVE.B      #$52,   (A6)+
        MOVE.B      #$4F,   (A6)+
        RTS

Buffer_BRA

Buffer_BHI

Buffer_BNE

Buffer_BEQ

Buffer_BLT
        
*----------------------------------------------------------------
*              Decode and Buffer Helper Routines                |
*----------------------------------------------------------------

Buffer8
        MOVE.B      #$38,   (A6)+
        RTS
        
Decode_OpCode_Size
        CLR         D5
        MOVE.B      var_opcode_size,    D5
        CMPI.B      #0, D5
        BEQ         BufferSizeByte
        CMPI.B      #1, D5
        BEQ         BufferSizeWord
        CMPI.B      #2, D5
        BEQ         BufferSizeLong
        BRA         error
        
Buffer_OpCode_Size_Group0000
        CLR         D5
        MOVE.B      var_opcode_size,    D5
        CMPI.B      #2,                 D5
        BEQ         BufferSizeWord
        CMPI.B      #3,                 D5
        BEQ         BufferSizeLong
        BNE         error
        
BufferSizeByte
        JSR         BufferPeriod
        MOVE.B      #$42,               (A6)+
        JSR         BufferTab
        BRA         Decode_OpCode_Size_Done

BufferSizeWord
        JSR         BufferPeriod
        MOVE.B      #$57,               (A6)+
        JSR         BufferTab
        BRA         Decode_OpCode_Size_Done
        
BufferSizeLong
        JSR         BufferPeriod
        MOVE.B      #$4C,               (A6)+
        JSR         BufferTab
        BRA         Decode_OpCode_Size_Done
        
Decode_OpCode_Size_Done
        CLR         D5
        RTS
        
Decode_OpCode_Direction
        CLR         D3
        MOVE.B      var_opcode_direction,   D3
        CMPI.B      #0,                     D3
        BEQ         BufferRight
        BNE         BufferLeft
        
BufferRight
        MOVE.B      #$52,               (A6)+
        RTS
        
BufferLeft
        MOVE.B      #$4C,               (A6)+
        RTS

Decode_Shift_Mid
        CLR         D3
        MOVE.B      #1,                 D3
        CMP.B       var_group1110_imme_or_reg,   D3
        BEQ         Decode_Shift_Reg
        BNE         Decode_Shift_Imme
        RTS

Decode_Shift_End
        CLR         D3
        MOVE.B      #3,                 D3
        CMP.B       var_opcode_size,    D3
        BEQ         Decode_Shift_EA
        BNE         Decode_Shift_Reg
        RTS

Decode_Shift_EA
        CLR         D3
        CLR         D4
        MOVE.B      #1,                         D3
        MOVE.B      var_opcode_dest_reg,        D4
        CMP.B       var_group1110_count_or_reg, D3
        BEQ         Decode_Shift_Mode
        BNE         Decode_Shift_Reg

Decode_Shift_Imme
        CLR         D4
        JSR         BufferHash
        JSR         BufferDollar
        CMP.B       var_group1110_count_or_reg, D4
        JSR         Decode_Shift_Xn
        RTS
        
Decode_Shift_Mode
        CLR         D2
        CLR         D3
        MOVE.B      var_opcode_dest_mode,       D2
        MOVE.B      var_opcode_dest_reg,        D3
        JSR         Decode_CompareMode
        RTS
        
Decode_Shift_Reg
        JSR         BufferDataReg
        JSR         Decode_Shift_Xn
        RTS
        
Decode_Shift_Xn
        CLR         D2
        CLR         D3
        MOVE.B      D4,                 D3
        ROR.L       #4,                 D3
        MOVE.B      #0,                 D2
        CMP.B       var_group1110_imme_or_reg,  D2
        BEQ         Decode_Shift_Xn_Compare
        MOVE.B      D3,                 D5
        CLR.B       var_decode_length
        MOVE.B      #1,                 var_decode_length
        JSR         HexToChar
        RTS
        
Decode_Shift_Xn_Compare
        CMPI.B      #0,                 D4
        BEQ         Buffer8
        MOVE.B      #1,                 var_opcode_data_size
        MOVE.L      D3,                 var_opcode_data
        JSR         Buffer_Data
        RTS
        

*----------------------------------------------------------------
*              Immediate Data Store Routines                    |
*----------------------------------------------------------------

Decode_StoreData_Byte
        CLR         D3
        CLR         D4
        CLR.L       var_opcode_data
        MOVE.W      (A5)+,              D4
        MOVE.W      #SHIFT24,           D3
        LSL.L       D3,                 D4
        MOVE.L      D4,                 var_opcode_data
        RTS

Decode_StoreData_Word
        CLR         D3
        CLR         D4
        CLR.L       var_opcode_data
        MOVE.W      (A5)+,              D4
        MOVE.W      #SHIFT16,           D3
        LSL.L       D3,                 D4
        MOVE.L      D4,                 var_opcode_data
        RTS

Decode_StoreData_Long
        CLR         D4
        CLR.L       var_opcode_data
        MOVE.W      (A5)+,              D4
        MOVE.L      D4,                 var_opcode_data
        RTS

Decode_GetIDataBySize
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
*              Immediate Data Buffer Routines                   |
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

Decode_CompareMode     
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
        CMPI.B  #%100,          D3
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
        MOVE.B  var_opcode_size,    D4
        CMPI.B  #%01,               D4
        BEQ     Buffer_GetByte
        CMPI.B  #%11,               D4
        BEQ     Buffer_GetWord
        CMPI.B  #%10,               D4
        BEQ     Buffer_GetLong
        BRA     error
        
ImmediateData_TypeSize1
        MOVE.B  var_opcode_size,    D4
        CMPI.B  #%0,                D4
        BEQ     Buffer_GetWord
        CMPI.B  #%1,                D4
        BEQ     Buffer_GetLong
        BRA     error
        
ImmediateData_TypeSize2
        MOVE.B  var_opcode_size,    D4
        CMPI.B  #%00,               D4
        BEQ     Buffer_GetByte
        CMPI.B  #%10,               D4
        BEQ     Buffer_GetWord
        CMPI.B  #%11,               D4
        BEQ     Buffer_GetLong
        BRA     error
        
Buffer_Data
        CLR     D5
        MOVE.L  var_opcode_data,        D5
        MOVE.B  var_opcode_data_size,   var_decode_length
        JSR     HexToChar
        RTS
        
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
        MOVE.B  D5, D3
        LSL.B   #4, D3
        LSR.B   #4, D3
        JSR     HexToChar_NumOrLetter
        MOVE.B  var_decode_length,  D1
        CMP.B   var_decode_counter, D1
        BNE     HexToChar_Loop
        CLR     D1
        CLR     D3
        CLR     D5
        RTS
        
HexToChar_NumOrLetter
        CMPI.B  #%1010, D3
        BGE     HexToChar_Letter
        BLT     HexToChar_Number
        
HexToChar_Letter
        ADDI.B  #$37,   D3
        MOVE.B  D3,     (A6)+
        RTS

HexToChar_Number
        ADDI.B  #$30,   D3
        MOVE.B  D3,     (A6)+
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
        
Buffer_PrepareSrcReg_OnD3
        CLR     D3
        MOVE.B  var_opcode_src_reg,     D3
        RTS
        
Buffer_PrepareDestReg_OnD3
        CLR     D3
        MOVE.B  var_opcode_dest_reg,    D3
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
        MOVE.B  #$28,   (A6)+
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
        
BufferPeriod
        MOVE.B  #$2E,   (A6)+
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
msg_start_request   DC.B    'Please enter a starting address: ',0
msg_end_request     DC.B    'Please enter a ending address: ',0
msg_continue_request    DC.B    'Hit any key to continue...',0
msg_goagain_request     DC.B    'Would you like to dissassemble a new location?',CR,LF
                        DC.B    'Type (y)es or (n)o and hit "Enter"',0
msg_thanks              DC.B    'Thanks for using the TeamReliable Disassembler!',CR,LF
                        DC.B    'Please give us money. ',0
msg_blank               DC.B    '',0
msg_morework            DC.B    'Guess who still has more work to do',CR,LF,0

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
var_opcode_data_size    DS.B    1
var_opcode_data         DS.L    1
var_opcode_direction    DS.B    1

var_group0100_id        DS.B    1
var_group0100_id_LEA    DS.B    1

var_group1110_imme_or_reg       DS.B    1
var_group1110_count_or_reg      DS.B    1
var_group1110_shift_or_rotate   DS.B    1

var_group0110_condition     DS.B    1
var_group0110_displacement  DS.B    1

var_decode_counter          DS.B    1
var_decode_length           DS.B    1
var_decode_buffer_data_flag DS.B    1

var_num_displayed   DS.W    1

var_line_addr       DS.L    1
var_line_number     DS.W    1
var_output_buffer   DS.L    10

var_temp            DS.B    1

    END     START


























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
