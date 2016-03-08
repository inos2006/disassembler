*-----------------------------------------------------------
* Title      : Main File
*-----------------------------------------------------------
    ORG $1000
MAIN:
    
    JSR         io_welcome
    ; main loop of our program
    
    MOVEA.L      end_addr, A2 ; A2 represents our end address
    
MAIN_LOOP
    MOVEA.L      curr_addr, A1   ; A1 is our current address
                                ; we read current address each time since it may be changed by opcode routines
    CMPA.L      A1, A2
    BLT         EXIT_MAIN_LOOP
    JSR         opcode_read_one
    BRA         MAIN_LOOP
EXIT_MAIN_LOOP
    
    INCLUDE 'opcode.x68'
    INCLUDE 'ea.x68'
    INCLUDE 'io.x68'
    INCLUDE 'variables.x68'
    INCLUDE 'strings.x68'
    INCLUDE 'test.x68'
    
    
    SIMHALT             ; halt simulator

STOP:
    END    MAIN



























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
