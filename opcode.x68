
; this subroutine reads one instruction and its address modes
; then changes curr_addr global variable to the next address
opcode_read_one:
    MOVEM.L     D0-D7/A0-A6, -(SP)

    LEA         opcode_jmp_table, A0
    CLR.L       D0

    MOVEA.L     curr_addr, A1
    MOVE.W      (A1),D0
    MOVE.B      #OPCODE_SHIFT, D1
    LSR.W       D1,D0 ; shift bits to get reamining 4 bytes
    MULU        #6,D0 ; we multiply by 6 since each line in jmp_table takes 6 bytes  ????????
    JSR         0(A0,D0) ; Jump indirect with index  ?????????????
	  BRA			END_JMP_TABLE

opcode_jmp_table    JMP         opcode_0000
				    JMP         opcode_0001
				    JMP         opcode_0010
				    JMP         opcode_0011
				    JMP         opcode_0100
				    JMP         opcode_0101
				    JMP         opcode_0110
				    JMP         opcode_0111
				    JMP         opcode_1000
				    JMP         opcode_1001
				    JMP         opcode_1010
				    JMP         opcode_1011
				    JMP         opcode_1100
				    JMP         opcode_1101
				    JMP         opcode_1110
				    JMP         opcode_1111

END_JMP_TABLE
    MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS

opcode_0000:
opcode_0001: ; moveb
opcode_0010: ; movel
opcode_0011: ; movew

*******************************MOVE****************************
	MOVEM.L     D0-D7/A0-A6, -(SP)

	MOVEA.L		curr_addr, A0
	MOVE.W		(A0), D2
	MOVE.W      #OPCODE_SHIFT, D1
	LSR.W		D1, D2	; now we are left with bits representing size of the operands
						; since first 2 bits are 00

	; TODO: check for illegal EA modes
	
	; size will just determine what we print to the screen, it doesn't impact addressing modes
	CMP.W		#1, D2 ; if bytes
	BEQ			OPCODE_DO_MOVEB
	CMP.W		#2, D2 ; if long
	BEQ			OPCODE_DO_MOVEL
	CMP.W		#3, D2 ; if word
	BEQ			OPCODE_DO_MOVEW
	STOP		#$2700

OPCODE_DO_MOVEB
	LEA			OPCODE_STRING_MOVEB, A3
	BRA			OPCODE_DO_MOVENEXT
OPCODE_DO_MOVEL
	LEA			OPCODE_STRING_MOVEL, A3
	BRA			OPCODE_DO_MOVENEXT
OPCODE_DO_MOVEW
	LEA			OPCODE_STRING_MOVEW, A3
	BRA			OPCODE_DO_MOVENEXT
OPCODE_DO_MOVENEXT
	MOVE.L		A0, D1
	JSR			io_print_opcode
	MOVEA.L     A0,A1 * save original instrcution adress since we need it
	ADDA		#2, A0

	; source
	MOVE.W		D2, D3

	MOVE.L		A0, D2

	MOVE.W		(A1),D0
	MOVE.W      #13, D4
	LSL.W		D4, D0
	LSR.W		D4, D0

	MOVE.W		(A1),D1
	MOVE.W      #10, D4
	LSL.W		D4, D1
	MOVE.W      #13, D4
	LSR.W		D4, D1

	JSR			ea_find_mode
	MOVE.L		D2, curr_addr
	MOVE.L      curr_addr, A0
	JSR         io_print_comma


	; destination
	MOVE.W		(A1),D0
	MOVE.W      #4, D4
	LSL.W		D4, D0
	MOVE.W      #13, D4
	LSR.W		D4, D0

	MOVE.W		(A1),D1
	MOVE.W      #7, D4
	LSL.W		D4, D1
	MOVE.W      #13, D4
	LSR.W		D4, D1

	JSR			ea_find_mode
	MOVE.L		D2, curr_addr



	; TODO print ea  // YAPTI GALIBA
	JSR			io_print_newline
	; current address must have been incremeented by ea subrooutines so we don't change it

	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS
*************************MOVE END***************************


opcode_0100
	MOVEM.L     D0-D7/A0-A6, -(SP)
	; NOP opcode
	MOVEA.L		curr_addr, A0
	MOVE.W		(A0),D3
	MOVE.L		A0, D1

	*check if it is NOP
	CMP.W		#OPCODE_NOP, D3
	BEQ			OPCODE_DO_NOP

    *check if it is RTS
	CMP.W		#OPCODE_RTS, D3
	BEQ			OPCODE_DO_RTS

	*check if it is LEA 
	MOVE.W      D3, D2

	MOVE.W      #7, D5 * 
	LSL.W		D5, D2	
	MOVE.W      #13, D5 * 
	LSR.W		D5, D2	

	CMP.W       #OPCODE_LEA, D2
	BEQ			OPCODE_DO_LEA

	*check if it is CLR

	MOVE.W      #8, D5 * To get rid of last 8 bits
	MOVE.W      D3,D2
	LSR.W		D5, D2	; now we are left with bits representing whether its CLR
	CMP.W       #OPCODE_CLR, D2
	BEQ			OPCODE_DO_CLR

	*check if it is JSR

	MOVE.W      #6, D5 * To get rid of last 6 bits
	MOVE.W      D3,D2
	LSR.W		D5, D2	; now we are left with bits representing whether its JSR
	CMP.W       #OPCODE_JSR, D2
	BEQ			OPCODE_DO_JSR

	STOP		#$2700
****************************NOP***************************
OPCODE_DO_NOP
	LEA			OPCODE_STRING_NOP, A3
	JSR			io_print_opcode
	JSR			io_print_newline
	ADDA		#2, A0
	MOVEM.L		A0, (curr_addr)

	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS
*************************NOP END**************************



****************************RTS***************************
OPCODE_DO_RTS
    LEA			OPCODE_STRING_RTS, A3
	JSR			io_print_opcode
	JSR			io_print_newline
	ADDA		#2, A0
	MOVEM.L		A0, (curr_addr)

	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS
**********************RTS END*****************************


****************************LEA***************************

OPCODE_DO_LEA
	ADDA		#2, A0
	MOVEM.L		A0, (curr_addr)
	LEA         OPCODE_STRING_LEA, A3
	JSR 		io_print_opcode
	
	* lea ea mode( pass with d1)

	MOVE.W		(A1),D1
	MOVE.W      #10, D4
	LSL.W		D4, D1 * shift 10 to left
	LSR.W		D4, D1 * shift back
    MOVE.W      #3, D4
    LSR.W		D4, D1 * shift 3 to right

 
   	* lea ea register ( pass with d0)
	MOVE.W		(A1),D0
	MOVE.W      #13, D4
	LSL.W		D4, D0 * shift 13 left
	LSR.W		D4, D0 * shift back

	JSR			ea_find_mode  *same as move destination TODO: KULSOOM SHOULD WRITE EA_FIND_LEA_MODE 
	JSR         io_print_comma
  

	*find register ( print function reads from D5)
	MOVE.W		(A1),D5
	MOVE.W      #4, D4
	LSL.W		D4, D5 * shift 4 to left
	LSR.W		D4, D5 * shift back
    MOVE.W      #9, D4
    LSR.W		D4, D5 * shift 9 to right

    JSR         io_print_address_register
    JSR         io_print_newline


	MOVE.L		D2, curr_addr

    MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS





****************************END LEA************************
****************************CLR***************************
OPCODE_DO_CLR
	ADDA		#2, A0
	MOVEM.L		A0, (curr_addr)

	* CLR find size 
	MOVE.W		(A1), D3
	MOVE.W      #8, D4
	LSL.W		D4, D3 * shift 8 to left
    LSR.W		D4, D3 * shift back
    MOVE.W      #6, D4
    LSR.W		D4, D3 * shift 6 bits to right 
    MOVE.W      A1, D1 * copy current address to print

    CMP.W		#0, D3 ; if bytes
	BEQ			OPCODE_DO_CLRB
	CMP.W		#1, D3 ; if word
	BEQ			OPCODE_DO_CLRW
	CMP.W		#2, D3 ; if long
	BEQ			OPCODE_DO_CLRL
	STOP		#$2700
OPCODE_DO_CLRB
	LEA			OPCODE_STRING_CLRB, A3
	BRA			OPCODE_DO_EFFECTIVEADDRESS

OPCODE_DO_CLRL
	LEA			OPCODE_STRING_CLRL, A3
	BRA			OPCODE_DO_EFFECTIVEADDRESS

OPCODE_DO_CLRW
	LEA			OPCODE_STRING_CLRW, A3
	BRA			OPCODE_DO_EFFECTIVEADDRESS

OPCODE_DO_EFFECTIVEADDRESS
	JSR         io_print_opcode
	* CLR mode (pass with d1)
	MOVE.W		(A1),D1
	MOVE.W      #10, D4
	LSL.W		D4, D1 * shift 10 to left
	LSR.W		D4, D1 * shift back
    MOVE.W      #3, D4
    LSR.W		D4, D1 * shift 3 to right

    * CLR register (pass with d0)
    MOVE.W		(A1),D0
	MOVE.W      #13, D4
	LSL.W		D4, D0 * shift 10 to left
	LSR.W		D4, D0 * shift back
  
    JSR			ea_find_mode  *same as move destination 
    JSR         io_print_newline

	MOVE.L		D2, curr_addr

    MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS



*************************END CLR***************************
***********************JSR********************************
OPCODE_DO_JSR
	LEA			OPCODE_STRING_JSR,A3
	JSR         io_print_opcode
	JSR         io_print_newline
	ADDA		#2, A0
	MOVEM.L		A0, (curr_addr)
	BRA			OPCODE_DO_JSR_NEXT

OPCODE_DO_JSR_NEXT
	
	* jsr mode (pass with d1)
	MOVE.W		(A1),D1
	MOVE.W      #10, D4
	LSL.W		D4, D1 * shift 10 to left
	LSR.W		D4, D1 * shift back
    MOVE.W      #3, D4
    LSR.W		D4, D1 * shift 3 to right



	* jsr register ( pass with d0)
	MOVE.W		(A1),D0
	MOVE.W      #13, D4
	LSL.W		D4, D0 * shift 13 left
	LSR.W		D4, D0 * shift back

	JSR			ea_jsr *** not in ea file yet / kulsoom will add
	MOVE.L		D2, curr_addr

    MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS


*************************JSR END*******************************

opcode_0101		STOP	#$2700
opcode_0110		STOP	#$2700
opcode_0111		STOP	#$2700
opcode_1000		STOP	#$2700
opcode_1001		STOP	#$2700
opcode_1010		STOP	#$2700
opcode_1011		STOP	#$2700
opcode_1100		STOP	#$2700
opcode_1101		STOP	#$2700
opcode_1110		STOP	#$2700
opcode_1111		STOP	#$2700









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
