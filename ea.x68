; finds and prints effective address
; pass 3 register bits  in D0.W
; pass 3 mode bits in D1.W
; pass next address to read in D2.L
; pass length bits in D3.B
; returns next address in D2.L, it may be same as original D2.L if address doesn't change
; otherwise moves address for the number of bytes read (if any)
ea_find_mode:
	MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
	
	CMP.W		#%111, D1
	BEQ			EA_FIND_IMMEDIATE_MODE

	CMP.W		#%000, D1
	BEQ			EA_DATA_REGISTER

	CMP.W		#%001, D1
	BEQ			EA_ADDRESS_REGISTER

	CMP.W		#%010, D1
	BEQ			EA_ADDRESS_REGISTER_INDIRECT
	
	CMP.W		#%011, D1
	BEQ			EA_ADDR_REG_IND_POST

	CMP.W		#%100, D1
	BEQ			EA_ADDR_REG_IND_PRE

	BRA			EA_FIND_REGISTER_MODE
	
EA_FIND_IMMEDIATE_MODE * this can be either immediate data or absolute adress 
	CMP.W		#%100, D0
	BEQ			EA_FIND_IMMEDIATE_DATA_MODE
	CMP.W		#%000, D0
	BEQ			EA_FIND_IMMEDIATE_WORD_ABS_MODE	
	CMP.W		#%001, D0
	BEQ			EA_FIND_IMMEDIATE_LONG_ABS_MODE	
	STOP		#$2700 ; error, we shouldn't hit this instruction

EA_FIND_IMMEDIATE_DATA_MODE
	MOVEA.L		D2, A0
    CMP.B		#%01, D3 ; byte
	BEQ			EA_FIND_READ_IMM_BYTE
	CMP.B		#%10, D3 ; long
	BEQ			EA_FIND_READ_IMM_LONG
	CMP.B 		#%11, D3 ; word
	BEQ			EA_FIND_READ_IMM_WORD
	STOP		#$2700 ; error, we shouldn't hit this instruction

EA_FIND_READ_IMM_BYTE
	CLR.L		D4
	MOVE.W		(A0)+, D4 ; this should byte instead of word but somehow simulator keeps word size space for imemdiate data
						  ; even if it is smaller
	JSR			io_print_imm_data

	BRA			EA_FIND_READ_COMMON

EA_FIND_READ_IMM_LONG
	MOVE.L		(A0)+, D4
	JSR			io_print_imm_data
	BRA			EA_FIND_READ_COMMON

EA_FIND_READ_IMM_WORD
	CLR.L			D4
	MOVE.W		(A0)+, D4
    JSR			io_print_imm_data
	BRA			EA_FIND_READ_COMMON

EA_FIND_IMMEDIATE_LONG_ABS_MODE
	MOVE.L		(A0)+, D4
    JSR			io_print_adress
	BRA			EA_FIND_READ_COMMON

EA_FIND_IMMEDIATE_WORD_ABS_MODE
	MOVE.W		(A0)+, D4
    JSR			io_print_adress
	BRA			EA_FIND_READ_COMMON

EA_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			EA_FIND_DONE

EA_FIND_REGISTER_MODE
	; print ea

EA_DATA_REGISTER_MOVE
	MOVE.W		D0, D5
	JSR			io_print_data_register
	
	BRA			EA_FIND_READ_COMMON
	
EA_ADDRESS_REGISTER_MOVE
	MOVE.W		D0, D5
	JSR			io_print_address_register
	
	BRA			EA_FIND_READ_COMMON

EA_ADDRESS_REGISTER_INDIRECT
	MOVE.W		D0, D5
	JSR			io_print_adr_reg_indirect
	
	BRA			EA_FIND_READ_COMMON

EA_ADDR_REG_IND_POST
	MOVE.W		D0, D5
	JSR			io_print_adr_reg_ind_post
	
	BRA			EA_FIND_READ_COMMON

EA_ADDR_REG_IND_PRE
	MOVE.W		D0, D5
	JSR			io_print_adr_reg_ind_pre
	
	BRA			EA_FIND_READ_COMMON
	
EA_FIND_DONE
	MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
    
    
***************KULSOOM STARTS FROM HERE ************************************************



      *******************************************************************************

*3/4/16 Kulsoom Mansoor
*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*!!!!!!!!!!NOT FINISHED!!!!DON'T KNOW HOW TO DO ABSOLUTE ADDRESS
*=================================================================================
*JSR 
*=================================================================================   
ea_jsr
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    
    CMP.W		#$111, D1
	BEQ			EA_JSR_ABSOLUTE_ADDRESS
	CMP.B       #$010, D1
	BEQ         EA_JSR_INDIRECT_ADDRESS
	*BRA         EA_JSR_INCORRECT_OPERAND
    STOP        #$2700        
	
EA_JSR_ABSOLUTE_ADDRESS
    CMP.W		#$000, D0
	BEQ			EA_JSR_ABS_ADDR_WORD	
	CMP.W		#$001, D0
	BEQ			EA_JSR_ABS_ADDR_LONG
	*BRA         EA_JSR_INCORRECT_OPERAND
	STOP        #$2700
EA_JSR_INDIRECT_ADDRESS
    JSR         ea_indirect_address
    BRA         EA_JSR_FIND_READ_COMMON

EA_JSR_ABS_ADDR_LONG *TODO-------------------------------------------------------------------------------------------------------------------	
    MOVE.L		(A0)+, D4
    JSR			io_print_adress
	BRA			EA_JSR_FIND_READ_COMMON
EA_JSR_ABS_ADDR_WORD *TODO------------------------------------------------------------------------------------------------------------------
	MOVE.W		(A0)+, D4
    JSR			io_print_adress
	BRA			EA_JSR_FIND_READ_COMMON *WHAT IS THIS FOR???? ------------------------------------------------------------------------

EA_JSR_INCORRECT_OPERAND
    STOP		#$2700 ; 
EA_JSR_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_jsr_done   
ea_jsr_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*!!!!!!!!!!NOT FINISHED!!!!DON'T KNOW HOW TO DO ABSOLUTE ADDRESS
*=================================================================================
*CLR 
*=================================================================================
ea_clr
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W		#$111, D1
	BEQ			EA_CLR_ABSOLUTE_ADDRESS
	CMP.W       #$010, D1
	BEQ         EA_CLR_INDIRECT_ADDRESS
	CMP.W       #$000, D1
	BEQ         EA_CLR_DATA_REG
	CMP.W       #$011, D1
	BEQ         EA_CLR_ADDR_POSTINC
	CMP.W       #$100, D1
	BEQ         EA_CLR_ADDR_PREDEC
	BRA         EA_CLR_INCORRECT_OPERAND
	
EA_CLR_ABSOLUTE_ADDRESS *TODO----------------------------------------------------------------------------------------------------------------
    CMP.W		#$000, D0
	BEQ			EA_CLR_ABS_ADDR_WORD	
	CMP.W		#$001, D0
	BEQ			EA_CLR_ABS_ADDR_LONG
	BRA         EA_CLR_INCORRECT_OPERAND	
EA_CLR_INDIRECT_ADDRESS
    JSR         ea_indirect_address
    BRA         EA_CLR_FIND_READ_COMMON    
EA_CLR_DATA_REG
    JSR         ea_data_register
    BRA         EA_CLR_FIND_READ_COMMON    
EA_CLR_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_CLR_FIND_READ_COMMON
EA_CLR_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_CLR_FIND_READ_COMMON    
EA_CLR_ABS_ADDR_WORD *TODO------------------------------------------------------------------------------------------------------
    MOVE.L		(A0)+, D4
    JSR			io_print_adress
	BRA			EA_CLR_FIND_READ_COMMON
EA_CLR_ABS_ADDR_LONG *TODO------------------------------------------------------------------------------------------------------
    MOVE.L		(A0)+, D4
    JSR			io_print_adress
	BRA			EA_CLR_FIND_READ_COMMON
EA_CLR_INCORRECT_OPERAND
    STOP		#$2700 ; error, we shouldn't hit this instruction -- DISPLAY ERROR MESSAGE -------------------------------------------

EA_CLR_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_jsr_done    
ea_clr_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS



*EA is only for the source operand    
*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W
*!!!!!!!!!!NOT FINISHED!!!!DON'T KNOW HOW TO DO ABSOLUTE ADDRESS 
*=================================================================================
*LEA
*=================================================================================
ea_lea
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$010, D1
    BEQ         EA_LEA_INDIRECT_ADDRESS
    CMP.W       #$111, D1
    BEQ         EA_LEA_ABS_ADDR
    STOP        #$2700
    
EA_LEA_INDIRECT_ADDRESS
    JSR         ea_indirect_address
    BRA         EA_LEA_FIND_READ_COMMON    
EA_LEA_ABS_ADDR
    *TODO ------------------------------------------------------------------------------------------------------------------------------
    
EA_LEA_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_lea_done
ea_lea_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS

*Source operand only    
*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W
*GOTTA FIGURE OUT ABSOLUTE ADDRESS AND IMMEDIATE DATA 
*=================================================================================
*CMP 
*=================================================================================
ea_cmp
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D1
    BEQ         EA_CMP_DATA_REG
    CMP.W       #$001, D1
    BEQ         EA_CMP_ADDR_REG
    CMP.W       #$010, D1
    BEQ         EA_CMP_INDIRECT_ADDR
    CMP.W       #$011, D1
    BEQ         EA_CMP_ADDR_POSTINC
    CMP.W       #$100, D1
    BEQ         EA_CMP_ADDR_PREDEC
    CMP.W       #$111, D1
    BEQ         EA_CMP_IMMEDIATE *TODO ----------------------------------------------------------------------------------------------
    STOP        #$2600 *SHOULD NOT COME HERE
    
EA_CMP_DATA_REG
    JSR         ea_data_register
    BRA         EA_CMP_FIND_READ_COMMON    
EA_CMP_ADDR_REG
    JSR         ea_address_register
    BRA         EA_CMP_FIND_READ_COMMON    
EA_CMP_INDIRECT_ADDR
    JSR         ea_indirect_address
    BRA         EA_CMP_FIND_READ_COMMON    
EA_CMP_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_CMP_FIND_READ_COMMON    
EA_CMP_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_CMP_FIND_READ_COMMON    
EA_CMP_IMMEDIATE *TODO ---------------------------------------------------------------------------------------------------------------
    STOP        #$2700
  
EA_CMP_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_cmp_done
ea_cmp_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS

*SOURCE OPERAND ONLY    
*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*NEED TO FIGURE OUT ABSOLUTE ADDRESS AND IMMEDIATE DATA
*=================================================================================
*ADDA 
*=================================================================================
ea_adda
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D1
    BEQ         EA_ADDA_DATA_REG
    CMP.W       #$001, D1
    BEQ         EA_ADDA_ADDR_REG
    CMP.W       #$010, D1
    BEQ         EA_ADDA_INDIRECT_ADDR
    CMP.W       #$011, D1
    BEQ         EA_ADDA_ADDR_POSTINC
    CMP.W       #$100, D1
    BEQ         EA_ADDA_ADDR_PREDEC
    CMP.W       #$111, D1
    BEQ         EA_ADDA_IMMEDIATE *TODO ----------------------------------------------------------------------------------------------
    STOP        #$2600 *SHOULD NOT COME HERE
    
EA_ADDA_DATA_REG
    JSR         ea_data_register
    BRA         EA_ADDA_FIND_READ_COMMON    
EA_ADDA_ADDR_REG
    JSR         ea_address_register
    BRA         EA_ADDA_FIND_READ_COMMON    
EA_ADDA_INDIRECT_ADDR
    JSR         ea_indirect_address
    BRA         EA_ADDA_FIND_READ_COMMON    
EA_ADDA_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_ADDA_FIND_READ_COMMON    
EA_ADDA_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_ADDA_FIND_READ_COMMON    
EA_ADDA_IMMEDIATE *TODO ---------------------------------------------------------------------------------------------------------------
    STOP        #$2700
   
EA_ADDA_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_adda_done
ea_adda_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W
*SELEN NEEDS TO CHECK IF DESTINATION OPERAND IS IMMEDIATE DATA CUZ THAT IS INVALID-------------------------------------------------------------------
*NEED TO FIGURE OUT ABSOLUTE ADDRESS/IMMEDIATE DATA-------------------------------------------------------------------------------------------------- 
*=================================================================================
*AND 
*=================================================================================
ea_and
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D1
    BEQ         EA_AND_DATA_REG
    CMP.W       #$010, D1
    BEQ         EA_AND_INDIRECT_ADDR
    CMP.W       #$011, D1
    BEQ         EA_AND_ADDR_POSTINC
    CMP.W       #$100, D1
    BEQ         EA_AND_ADDR_PREDEC
    CMP.W       #$111, D1
    BEQ         EA_AND_IMMEDIATE *TODO ----------------------------------------------------------------------------------------------
    STOP        #$2600 *SHOULD NOT COME HERE
    
EA_AND_DATA_REG
    JSR         ea_data_register
    BRA         EA_AND_FIND_READ_COMMON
EA_AND_INDIRECT_ADDR
    JSR         ea_indirect_address
    BRA         EA_AND_FIND_READ_COMMON   
EA_AND_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_AND_FIND_READ_COMMON 
EA_AND_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_AND_FIND_READ_COMMON
EA_AND_IMMEDIATE *TODO ---------------------------------------------------------------------------------------------------------------
    STOP        #$2700
        
EA_AND_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_and_done
ea_and_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
    
*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*SUB 
*=================================================================================
*SUB.B source operand************************************************************
ea_sub_source_byte
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D1
    BEQ         EA_SUB_BYTE_S_DATA_REG
    CMP.W       #$002, D1
    BEQ         EA_SUB_BYTE_S_INDIRECT_ADDR
    CMP.W       #$003, D1
    BEQ         EA_SUB_BYTE_S_ADDR_POSTINC
    CMP.W       #$004, D1
    BEQ         EA_SUB_BYTE_S_ADDR_PREDEC
    CMP.W       #$007, D1
    BEQ         EA_SUB_BYTE_S_IMMEDIATE *TODO ----------------------------------------------------------------------------------------------
    STOP        #$2600 *SHOULD NOT COME HERE

EA_SUB_BYTE_S_DATA_REG
    JSR         ea_data_register
    BRA         EA_SUB_BYTE_S_FIND_READ_COMMON
EA_SUB_BYTE_S_INDIRECT_ADDR
    JSR         ea_indirect_address
    BRA         EA_SUB_BYTE_S_FIND_READ_COMMON
EA_SUB_BYTE_S_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_SUB_BYTE_S_FIND_READ_COMMON
EA_SUB_BYTE_S_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_SUB_BYTE_S_FIND_READ_COMMON
EA_SUB_BYTE_S_IMMEDIATE *TODO----------------------------------------------------------------------------------------------------------------

EA_SUB_BYTE_S_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_sub_source_byte_done
ea_sub_source_byte_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS

*SUB.W or SUB.L source operand************************************************************
ea_sub_source_not_byte
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D1
    BEQ         EA_SUB_S_DATA_REG
    CMP.W       #$001, D1
    BEQ         EA_SUB_S_ADDR_REG
    CMP.W       #$002, D1
    BEQ         EA_SUB_S_INDIRECT_ADDR
    CMP.W       #$003, D1
    BEQ         EA_SUB_S_ADDR_POSTINC
    CMP.W       #$004, D1
    BEQ         EA_SUB_S_ADDR_PREDEC
    CMP.W       #$007, D1
    BEQ         EA_SUB_S_IMMEDIATE *TODO ----------------------------------------------------------------------------------------------
    STOP        #$2600 *SHOULD NOT COME HERE

EA_SUB_S_DATA_REG
    JSR         ea_data_register
    BRA         EA_SUB_SOURCE_FIND_READ_COMMON
EA_SUB_S_ADDR_REG
    JSR         ea_address_register
    BRA         EA_SUB_SOURCE_FIND_READ_COMMON
EA_SUB_S_INDIRECT_ADDR
    JSR         ea_indirect_address
    BRA         EA_SUB_SOURCE_FIND_READ_COMMON
EA_SUB_S_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_SUB_SOURCE_FIND_READ_COMMON
EA_SUB_S_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_SUB_SOURCE_FIND_READ_COMMON
EA_SUB_S_IMMEDIATE *TODO----------------------------------------------------------------------------------------------------------------

EA_SUB_SOURCE_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_sub_source_not_byte_done
ea_sub_source_not_byte_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
*SUB destination operand********************************************************    
ea_sub_destination
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D1
    BEQ         EA_SUB_D_DATA_REG
    CMP.W       #$002, D1
    BEQ         EA_SUB_D_INDIRECT_ADDR
    CMP.W       #$003, D1
    BEQ         EA_SUB_D_ADDR_POSTINC
    CMP.W       #$004, D1
    BEQ         EA_SUB_D_ADDR_PREDEC
    CMP.W       #$007, D1
    BEQ         EA_SUB_D_ABS_ADDR *TODO ----------------------------------------------------------------------------------------------
    STOP        #$2600 *SHOULD NOT COME HERE
    
EA_SUB_D_DATA_REG
    JSR         ea_data_register
    BRA         EA_SUB_DEST_FIND_READ_COMMON
EA_SUB_D_INDIRECT_ADDR
    JSR         ea_indirect_address
    BRA         EA_SUB_DEST_FIND_READ_COMMON
EA_SUB_D_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_SUB_DEST_FIND_READ_COMMON
EA_SUB_D_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_SUB_DEST_FIND_READ_COMMON
EA_SUB_D_ABS_ADDR *TODO -------------------------------------------------------------------------------------------------------------------

EA_SUB_DEST_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_sub_dest_done
ea_sub_dest_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
    
*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*ADD 
*=================================================================================
*ADD.B source operand************************************************************
ea_add_source_byte
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D1
    BEQ         EA_ADD_BYTE_S_DATA_REG
    CMP.W       #$002, D1
    BEQ         EA_ADD_BYTE_S_INDIRECT_ADDR
    CMP.W       #$003, D1
    BEQ         EA_ADD_BYTE_S_ADDR_POSTINC
    CMP.W       #$004, D1
    BEQ         EA_ADD_BYTE_S_ADDR_PREDEC
    CMP.W       #$007, D1
    BEQ         EA_ADD_BYTE_S_IMMEDIATE *TODO ----------------------------------------------------------------------------------------------
    STOP        #$2600 *SHOULD NOT COME HERE

EA_ADD_BYTE_S_DATA_REG
    JSR         ea_data_register
    BRA         EA_ADD_BYTE_S_FIND_READ_COMMON
EA_ADD_BYTE_S_INDIRECT_ADDR
    JSR         ea_indirect_address
    BRA         EA_ADD_BYTE_S_FIND_READ_COMMON
EA_ADD_BYTE_S_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_ADD_BYTE_S_FIND_READ_COMMON
EA_ADD_BYTE_S_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_ADD_BYTE_S_FIND_READ_COMMON
EA_ADD_BYTE_S_IMMEDIATE *TODO----------------------------------------------------------------------------------------------------------------

EA_ADD_BYTE_S_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_add_byte_source_done
ea_add_byte_source_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS

*ADD.W or ADD.L source operand************************************************************
ea_add_source_not_byte
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D1
    BEQ         EA_ADD_S_DATA_REG
    CMP.W       #$001, D1
    BEQ         EA_ADD_S_ADDR_REG
    CMP.W       #$002, D1
    BEQ         EA_ADD_S_INDIRECT_ADDR
    CMP.W       #$003, D1
    BEQ         EA_ADD_S_ADDR_POSTINC
    CMP.W       #$004, D1
    BEQ         EA_ADD_S_ADDR_PREDEC
    CMP.W       #$007, D1
    BEQ         EA_ADD_S_IMMEDIATE *TODO ----------------------------------------------------------------------------------------------
    STOP        #$2600 *SHOULD NOT COME HERE

EA_ADD_S_DATA_REG
    JSR         ea_data_register
    BRA         EA_ADD_SOURCE_FIND_READ_COMMON
EA_ADD_S_ADDR_REG
    JSR         ea_address_register
    BRA         EA_ADD_SOURCE_FIND_READ_COMMON
EA_ADD_S_INDIRECT_ADDR
    JSR         ea_indirect_address
    BRA         EA_ADD_SOURCE_FIND_READ_COMMON
EA_ADD_S_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_ADD_SOURCE_FIND_READ_COMMON
EA_ADD_S_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_ADD_SOURCE_FIND_READ_COMMON
EA_ADD_S_IMMEDIATE *TODO----------------------------------------------------------------------------------------------------------------

EA_ADD_SOURCE_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_add_not_byte_source_done
ea_add_not_byte_source_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
*ADD destination operand********************************************************    
ea_add_destination
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D1
    BEQ         EA_ADD_D_DATA_REG
    CMP.W       #$002, D1
    BEQ         EA_ADD_D_INDIRECT_ADDR
    CMP.W       #$003, D1
    BEQ         EA_ADD_D_ADDR_POSTINC
    CMP.W       #$004, D1
    BEQ         EA_ADD_D_ADDR_PREDEC
    CMP.W       #$007, D1
    BEQ         EA_ADD_D_ABS_ADDR *TODO ----------------------------------------------------------------------------------------------
    STOP        #$2600 *SHOULD NOT COME HERE
    
EA_ADD_D_DATA_REG
    JSR         ea_data_register
    BRA         EA_ADD_DEST_FIND_READ_COMMON
EA_ADD_D_INDIRECT_ADDR
    JSR         ea_indirect_address
    BRA         EA_ADD_DEST_FIND_READ_COMMON
EA_ADD_D_ADDR_POSTINC
    JSR         ea_addr_postinc
    BRA         EA_ADD_DEST_FIND_READ_COMMON
EA_ADD_D_ADDR_PREDEC
    JSR         ea_addr_predec
    BRA         EA_ADD_DEST_FIND_READ_COMMON
EA_ADD_D_ABS_ADDR *TODO -------------------------------------------------------------------------------------------------------------------

EA_ADD_DEST_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_add_dest_done
ea_add_dest_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
    
*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*DIVU
*=================================================================================
ea_divu
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    
EA_DIVU_FIND_READ_COMMON
	MOVE.L		A0, D2
	BRA			ea_lea_done
ea_divu_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*ROR 
*=================================================================================

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*MULS 
*=================================================================================

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*LSL 
*=================================================================================

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*ADDI 
*=================================================================================

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*ASR 
*=================================================================================

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*BCC 
*=================================================================================

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*BGT 
*=================================================================================

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*BLE 
*=================================================================================

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*MOVEM 
*=================================================================================

*I am assuming that the register bits of destination operand is in D0.W and the 
*mode bits are in D1.W 
*=================================================================================
*MOVEQ 
*=================================================================================

*=================================================================================
*DETERMINING EA REGISTER BITS
*=================================================================================
*data register------------------------------------------------    
ea_data_register
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D0
    BEQ         EA_DR_0
    CMP.W       #$001, D0
    BEQ         EA_DR_1
    CMP.W       #$002, D0
    BEQ         EA_DR_2
    CMP.W       #$003, D0
    BEQ         EA_DR_3
    CMP.W       #$004, D0
    BEQ         EA_DR_4
    CMP.W       #$005, D0
    BEQ         EA_DR_5
    CMP.W       #$006, D0
    BEQ         EA_DR_6
    CMP.W       #$007, D0
    BEQ         EA_DR_7
    STOP        #$2700 *SHOULD NOT COME HERE

EA_DR_0
    JSR         EA_PRINT_DATA_REG_0
    BRA         ea_data_register_done
EA_DR_1
    JSR         EA_PRINT_DATA_REG_1
    BRA         ea_data_register_done
EA_DR_2
    JSR         EA_PRINT_DATA_REG_2
    BRA         ea_data_register_done
EA_DR_3
    JSR         EA_PRINT_DATA_REG_3
    BRA         ea_data_register_done
EA_DR_4
    JSR         EA_PRINT_DATA_REG_4
    BRA         ea_data_register_done
EA_DR_5
    JSR         EA_PRINT_DATA_REG_5
    BRA         ea_data_register_done
EA_DR_6
    JSR         EA_PRINT_DATA_REG_6
    BRA         ea_data_register_done
EA_DR_7
    JSR         EA_PRINT_DATA_REG_7
    BRA         ea_data_register_done
    
ea_data_register_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
    
*address register------------------------------------------------    
ea_address_register
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D0
    BEQ         EA_AR_0
    CMP.W       #$001, D0
    BEQ         EA_AR_1
    CMP.W       #$002, D0
    BEQ         EA_AR_2
    CMP.W       #$003, D0
    BEQ         EA_AR_3
    CMP.W       #$004, D0
    BEQ         EA_AR_4
    CMP.W       #$005, D0
    BEQ         EA_AR_5
    CMP.W       #$006, D0
    BEQ         EA_AR_6
    CMP.W       #$007, D0
    BEQ         EA_AR_7
    STOP        #$2700 *SHOULD NOT COME HERE

EA_AR_0
    JSR         EA_PRINT_ADDR_REG_0
    BRA         ea_address_register_done
EA_AR_1
    JSR         EA_PRINT_ADDR_REG_1
    BRA         ea_address_register_done
EA_AR_2
    JSR         EA_PRINT_ADDR_REG_2
    BRA         ea_address_register_done
EA_AR_3
    JSR         EA_PRINT_ADDR_REG_3
    BRA         ea_address_register_done
EA_AR_4
    JSR         EA_PRINT_ADDR_REG_4
    BRA         ea_address_register_done
EA_AR_5
    JSR         EA_PRINT_ADDR_REG_5
    BRA         ea_address_register_done
EA_AR_6
    JSR         EA_PRINT_ADDR_REG_6
    BRA         ea_address_register_done
EA_AR_7
    JSR         EA_PRINT_ADDR_REG_7
    BRA         ea_address_register_done

ea_address_register_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS

*indirect address------------------------------------------------    
ea_indirect_address
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D0
    BEQ         EA_IA_0
    CMP.W       #$001, D0
    BEQ         EA_IA_1
    CMP.W       #$002, D0
    BEQ         EA_IA_2
    CMP.W       #$003, D0
    BEQ         EA_IA_3
    CMP.W       #$004, D0
    BEQ         EA_IA_4
    CMP.W       #$005, D0
    BEQ         EA_IA_5
    CMP.W       #$006, D0
    BEQ         EA_IA_6
    CMP.W       #$007, D0
    BEQ         EA_IA_7
    STOP        #$2700 *SHOULD NOT COME HERE

EA_IA_0
    JSR         EA_PRINT_INDIRECT_ADDR_0
    BRA         ea_indirect_address_done
EA_IA_1
    JSR         EA_PRINT_INDIRECT_ADDR_1
    BRA         ea_indirect_address_done
EA_IA_2
    JSR         EA_PRINT_INDIRECT_ADDR_2
    BRA         ea_indirect_address_done
EA_IA_3
    JSR         EA_PRINT_INDIRECT_ADDR_3
    BRA         ea_indirect_address_done
EA_IA_4
    JSR         EA_PRINT_INDIRECT_ADDR_4
    BRA         ea_indirect_address_done
EA_IA_5
    JSR         EA_PRINT_INDIRECT_ADDR_5
    BRA         ea_indirect_address_done
EA_IA_6
    JSR         EA_PRINT_INDIRECT_ADDR_6
    BRA         ea_indirect_address_done
EA_IA_7
    JSR         EA_PRINT_INDIRECT_ADDR_7
    BRA         ea_indirect_address_done

ea_indirect_address_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
    
*address post-increment------------------------------------------------    
ea_addr_postinc
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D0
    BEQ         EA_PI_0
    CMP.W       #$001, D0
    BEQ         EA_PI_1
    CMP.W       #$002, D0
    BEQ         EA_PI_2
    CMP.W       #$003, D0
    BEQ         EA_PI_3
    CMP.W       #$004, D0
    BEQ         EA_PI_4
    CMP.W       #$005, D0
    BEQ         EA_PI_5
    CMP.W       #$006, D0
    BEQ         EA_PI_6
    CMP.W       #$007, D0
    BEQ         EA_PI_7
    STOP        #$2700 *SHOULD NOT COME HERE

EA_PI_0
    JSR         EA_PRINT_ADDR_POSTINC_0
    BRA         ea_addr_postinc_done
EA_PI_1
    JSR         EA_PRINT_ADDR_POSTINC_1
    BRA         ea_addr_postinc_done
EA_PI_2
    JSR         EA_PRINT_ADDR_POSTINC_2
    BRA         ea_addr_postinc_done
EA_PI_3
    JSR         EA_PRINT_ADDR_POSTINC_3
    BRA         ea_addr_postinc_done
EA_PI_4
    JSR         EA_PRINT_ADDR_POSTINC_4
    BRA         ea_addr_postinc_done
EA_PI_5
    JSR         EA_PRINT_ADDR_POSTINC_5
    BRA         ea_addr_postinc_done
EA_PI_6
    JSR         EA_PRINT_ADDR_POSTINC_6
    BRA         ea_addr_postinc_done
EA_PI_7
    JSR         EA_PRINT_ADDR_POSTINC_7
    BRA         ea_addr_postinc_done

ea_addr_postinc_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
    
*address pre-decrement------------------------------------------------    
ea_addr_predec
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    CMP.W       #$000, D0
    BEQ         EA_PD_0
    CMP.W       #$001, D0
    BEQ         EA_PD_1
    CMP.W       #$002, D0
    BEQ         EA_PD_2
    CMP.W       #$003, D0
    BEQ         EA_PD_3
    CMP.W       #$004, D0
    BEQ         EA_PD_4
    CMP.W       #$005, D0
    BEQ         EA_PD_5
    CMP.W       #$006, D0
    BEQ         EA_PD_6
    CMP.W       #$007, D0
    BEQ         EA_PD_7
    STOP        #$2700 *SHOULD NOT COME HERE

EA_PD_0
    JSR         EA_PRINT_ADDR_PREDEC_0
    BRA         ea_addr_predec_done
EA_PD_1
    JSR         EA_PRINT_ADDR_PREDEC_1
    BRA         ea_addr_predec_done
EA_PD_2
    JSR         EA_PRINT_ADDR_PREDEC_2
    BRA         ea_addr_predec_done
EA_PD_3
    JSR         EA_PRINT_ADDR_PREDEC_3
    BRA         ea_addr_predec_done
EA_PD_4
    JSR         EA_PRINT_ADDR_PREDEC_4
    BRA         ea_addr_predec_done
EA_PD_5
    JSR         EA_PRINT_ADDR_PREDEC_5
    BRA         ea_addr_predec_done
EA_PD_6
    JSR         EA_PRINT_ADDR_PREDEC_6
    BRA         ea_addr_predec_done
EA_PD_7
    JSR         EA_PRINT_ADDR_PREDEC_7
    BRA         ea_addr_predec_done

ea_addr_predec_done
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
    
*=================================================================================
*PRINTING SUBROUTINES 
*=================================================================================

*DATA REGISTERS------------------------------------------------------------------
EA_PRINT_DATA_REG_0
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_DATA_REG_0, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS    
EA_PRINT_DATA_REG_1
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_DATA_REG_1, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_DATA_REG_2
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_DATA_REG_2, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS  
EA_PRINT_DATA_REG_3
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_DATA_REG_3, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_DATA_REG_4
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_DATA_REG_4, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_DATA_REG_5
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_DATA_REG_5, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_DATA_REG_6
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_DATA_REG_6, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_DATA_REG_7
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_DATA_REG_7, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
*ADDRESS REGISTERS-------------------------------------------------  
EA_PRINT_ADDR_REG_0
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_REG_0, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_REG_1
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_REG_1, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_REG_2
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_REG_2, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_REG_3
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_REG_3, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_REG_4
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_REG_4, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_REG_5
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_REG_5, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_REG_6
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_REG_6, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_REG_7
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_REG_7, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
*INDIRECT ADDRESS-------------------------------------------------
EA_PRINT_INDIRECT_ADDR_0
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_INDIRECT_ADDRESS_0, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_INDIRECT_ADDR_1
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_INDIRECT_ADDRESS_1, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_INDIRECT_ADDR_2
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_INDIRECT_ADDRESS_2, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_INDIRECT_ADDR_3
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_INDIRECT_ADDRESS_3, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_INDIRECT_ADDR_4
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_INDIRECT_ADDRESS_4, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_INDIRECT_ADDR_5
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_INDIRECT_ADDRESS_5, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_INDIRECT_ADDR_6
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_INDIRECT_ADDRESS_6, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_INDIRECT_ADDR_7
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_INDIRECT_ADDRESS_7, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
*ADDRESS POSTINCREMENT------------------------------------------------    
EA_PRINT_ADDR_POSTINC_0
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_POSTINC_0, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_POSTINC_1
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_POSTINC_1, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_POSTINC_2
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_POSTINC_2, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_POSTINC_3
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_POSTINC_3, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_POSTINC_4
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_POSTINC_4, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_POSTINC_5
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_POSTINC_5, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_POSTINC_6
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_POSTINC_6, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_POSTINC_7
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_POSTINC_7, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
*ADDRESS PREDECREMENT------------------------------------------------    
EA_PRINT_ADDR_PREDEC_0
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_PREDEC_0, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_PREDEC_1
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_PREDEC_1, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_PREDEC_2
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_PREDEC_2, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_PREDEC_3
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_PREDEC_3, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_PREDEC_4
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_PREDEC_4, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_PREDEC_5
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_PREDEC_5, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_PREDEC_6
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_PREDEC_6, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS
EA_PRINT_ADDR_PREDEC_7
    MOVEM.L     D0/D1/D3-D7/A0-A6, -(SP)
    LEA         EA_STRING_ADDRESS_PREDEC_7, A1
    JSR         io_print_registers
    MOVEM.L     (SP)+, D0/D1/D3-D7/A0-A6
    RTS




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
