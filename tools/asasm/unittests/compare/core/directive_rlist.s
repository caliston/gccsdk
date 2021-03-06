; Tests RLIST

	AREA Code, CODE
	
	[ :LNOT: REFERENCE

RL1	RLIST {r0-r3, r7  ,r14}
RL2	RLIST { r5-r8  }

	LDMIA r13,RL1
	STMIA r13, RL2
	PUSH RL1
	POP RL2

	; Only LDM/STM can have ^ specified.
	LDMIA r13,RL1^
	STMIA r13, RL2^

	|

	LDMIA R13, {R0-R3, R7, R14}
	STMIA R13, {R5-R8}
	STMFD R13!, {R0-R3, R7, R14}
	LDMFD R13!, {R5-R8}

	LDMIA R13, {R0-R3, R7, R14}^
	STMIA R13, {R5-R8}^

	]

	END