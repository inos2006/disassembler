
	
	NOP
	MOVE.B		#20,$1020

	MOVE.L		$1010, $1030
	MOVE.W		$1040, $1050
	RTS
	CLR.B       D0

	MOVE.L		$1000, A1
	MOVE.L		A1, D1	
	CLR.W       $1000
	MOVE.L		(A1), D3	
	MOVE.L		-(A1), D4	
	MOVE.L		D7, -(A2)
	MOVE.L		(A2)+, D5
	MOVE.L		#3, (A2)
	LEA 		(A4), A3
	MOVE.L		$1000, $1020
	NOP
	MOVE.L		#16666, D1
	NOP
	
	MOVE.L		#16666, D1
	NOP
	NOP
	LEA         $1000, A0
	