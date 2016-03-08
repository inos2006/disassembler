; show welcome message and record start and end addresses
io_welcome:
         MOVEM.L     D0-D7/A0-A6, -(SP)

         LEA         WELCOME_MESSAGE, A1 *EA of message loaded to A1
         MOVE.B      #13, D0 
         TRAP        #15
    
		 JSR		 io_read_hex_address
		 MOVE.L		 D0, start_addr
		 MOVE.L      D0, curr_addr

		 JSR		 io_read_hex_address
	     MOVE.L      D0,end_addr  

         MOVEM.L     (SP)+, D0-D7/A0-A6
         RTS  

; reads a string in hex format converts it into an address
; the address will be returned in D0         
io_read_hex_address:
        MOVEM.L     D1-D7/A0-A6, -(SP)
        
        MOVE.B      #2, D0 ; trap #2 reads a string from standard input
        LEA		    string_buffer, A1 ; set buffer address
        TRAP        #15 ; keeps length in D1.W
        
		JSR			io_convert_string_to_decimal
		MOVE.L		D2, D0
        
        MOVEM.L     (SP)+, D1-D7/A0-A6
        RTS

; converts hex string into a number and returns number in D2
; pass string in A1, pass string length in D1.W
io_convert_string_to_decimal:
        MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
        
        CLR.W       D0 ; D0 is loop index
		CLR.L		D2 ; D4 is sum of hex 
		MOVEA.L		A1, A2 ; A2 keeps our current character to process
CONVERT_NUMBER_LOOP
        CMP.W       D0, D1
        BLE         CONVERT_NUMBER_LOOP_EXIT    

		CLR.L		D3 ; clear D3 to keep numeric value
		MOVE.B		(A2)+, D3 ; D3 now holds the ascii code of our current character
		
		; TODO what if address  is given with non-capital letters like abc1476f
		
		CMPI.W		#64, D3 ; this comparison checks if D3 is smaller than A (whose value is #65)
		BLT			HEX_NUMBER
		BRA			HEX_ALPHA
HEX_ALPHA
		SUBI.W		#55, D3 ; we subtracted 55 since value of hex A is 10
		BRA			HEX_DONE
HEX_NUMBER
		SUBI.W		#48, D3 ; #48 is the ascii code of 0
		BRA			HEX_DONE
HEX_DONE
		MULU		#16, D2 ; multiply existing sum with 16 since we are movingg to next digit
		ADD.L		D3, D2 ; add new digit 
		
		ADDI.W		#1, D0
		
        BRA         CONVERT_NUMBER_LOOP
CONVERT_NUMBER_LOOP_EXIT        

        MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
        RTS

; this prints opcodes with no effective addresses
; Pass current address in D1
; Pass instruction name in A3 
; example NOP
io_print_opcode:
	MOVEM.L     D0-D7/A0-A6, -(SP)
	
	; currently we are printing in decimal
	; TODO print in hex address format
	

		
    ****************
      MOVEQ   #15,D0
    MOVEQ   #16,D2
    MOVE.L  A0,D1
    TRAP    #15 *printing it out in hex
		 
    MOVEA.L     A3, A1
    MOVE.B      #14, D0 
    TRAP        #15
    
    
    MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS
    

   

*reads adress from D4.L
 io_print_adress:
	MOVEM.L     D0-D7/A0-A6, -(SP)

	
   
	LEA         DOLLAR_STRING, A1
    MOVE.B      #14, D0 
    TRAP        #15
* TODO currently we are printing adress in decimal convert it to hex 
    MOVE.L      D4,D1
    MOVE.B      #3, D0 
    TRAP        #15

	
	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS
    



*reads data from D4.L
io_print_imm_data:
	MOVEM.L     D0-D7/A0-A6, -(SP)
   
	LEA         POUND_STRING, A1
    MOVE.B      #14, D0 
    TRAP        #15

    MOVE.L      D4,D1
    MOVE.B      #3, D0 
    TRAP        #15

	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS
	


io_print_comma:
	MOVEM.L     D0-D7/A0-A6, -(SP)
	
	LEA			COMMA_STRING, A1
	MOVE.B      #14, D0
	TRAP        #15
	
	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS


io_print_newline:
	MOVEM.L     D0-D7/A0-A6, -(SP)
	
	LEA			EMPTY_STRING, A1
	MOVE.B      #13, D0
	TRAP        #15
	
	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS

* reads register # from D5
io_print_data_register:
	MOVEM.L     D0-D7/A0-A6, -(SP)
   
	LEA         DATA_REGISTER_STRING, A1
    MOVE.B      #14, D0 
    TRAP        #15

    MOVE.L      D5,D1
    MOVE.B      #3, D0 
    TRAP        #15
	
	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS

* reads register # from D5
io_print_address_register:
	MOVEM.L     D0-D7/A0-A6, -(SP)
   
	LEA         ADDRESS_REGISTER_STRING, A1
    MOVE.B      #14, D0 
    TRAP        #15

    MOVE.L      D5,D1
    MOVE.B      #3, D0 
    TRAP        #15
	
	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS


io_print_adr_reg_indirect:
	MOVEM.L     D0-D7/A0-A6, -(SP)
   
	LEA         LEFT_PARANTHESIS_STRING, A1
    MOVE.B      #14, D0 
    TRAP        #15

	JSR			io_print_address_register

	LEA         RIGHT_PARANTHESIS_STRING, A1
    MOVE.B      #14, D0 
    TRAP        #15
	
	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS

io_print_adr_reg_ind_post:
	MOVEM.L     D0-D7/A0-A6, -(SP)
   
	JSR			io_print_adr_reg_indirect

	LEA         PLUS_STRING, A1
    MOVE.B      #14, D0 
    TRAP        #15
	
	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS
	
io_print_adr_reg_ind_pre:
	MOVEM.L     D0-D7/A0-A6, -(SP)
   
	LEA         MINUS_STRING, A1
    MOVE.B      #14, D0 
    TRAP        #15

	JSR			io_print_adr_reg_indirect

	MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS


 *3/31/16 Kulsoom Mansoor
*to print out the data registers, address registers, post-increment, and pre-decrement    
io_print_registers:
    MOVEM.L     D0-D7/A0-A6, -(SP)
    
    MOVE.B      #14, D0
    TRAP        #15

    MOVEM.L     (SP)+, D0-D7/A0-A6
    RTS
    
    ********************
    *VARSHA CODE
    
; Validates the length of input
io_isvalid_length
        CLR.L   D4                  ;Empty D4 to store new test result
        MOVEQ   #$0,D5              ;Empty D5 to test null condition of input 
        CMP.B   D5,D1               ;Compare if input length == 0
        BEQ     io_print_errorlen   ;Input is invalid (null)            
        CMPI    #$8,D1              ;Validate if input longer than 8 bytes
        BGT     io_print_errorlen   ;Input is invalid
        MOVE.B  #$1,D4              ;Set D4 to 1 as input is valid
        RTS

; Validate odd/even length       
io_isvalid_format
        CLR.L       D2             	    ;Empty D2
        CLR.L       D4             	    ;Empty D4 to store new test results
        MOVE.W      D3,D2          	    ;Copy address to D2
        MOVE.L      #$00000002,D1  	    ;Store 2 in D1 for determination of odd/even
        DIVU        D1,D2          	    ;Divide the input address by 2
        SWAP        D2             	    ;Store the remainder in D2
        CMP.B       #1,D2          	    ;Is the remainder == 1
        BEQ         io_print_errorfmt   ;Input fails odd test as remainder is 1
        MOVE.B      #$1,D4              ;Odd test passed
        RTS 
        
; prints error message for length validation failure
io_print_errorlen
        LEA     MSG_INVALIDLEN,A1  	;Load error message to A1
        MOVE.B  #14,D0          	;Print odd address error message
        TRAP    #15
        MOVEQ   #$0,D4              ;test fail in D4 denoted by 0
        RTS                

; prints error message for address format failure
io_print_errorfmt
        LEA     MSG_ODDADDR,A1  	;Load error message to A1
        MOVE.B  #14,D0          	;Print error message to screen
        TRAP    #15                     
        MOVEQ   #$0,D4          	;Set D4 to 0 (Test failed)
        CLR.L   D3              	;Empty the address for redo
        RTS 
****************************************************************



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
