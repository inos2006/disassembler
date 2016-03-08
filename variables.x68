start_addr      DS.L    1
end_addr        DS.L    1
curr_addr       DS.L    1

string_buffer   DS.B    80 ; trap #2 can read 80 characters, allocate max buffer size available

OPCODE_SHIFT    EQU 12 ; number of bits to shift for reading opcode


; opcode consts
OPCODE_NOP		EQU %0100111001110001
OPCODE_RTS      EQU %0100111001110101
OPCODE_JSR		EQU %0100111010  
OPCODE_CLR		EQU %01000010 
OPCODE_LEA		EQU %111



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
