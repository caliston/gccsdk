; s.stubs
; Provides an Object Format file for linking with the SharedCLibrary
; (c) Copyright 1997, 1999, 2001 Nick Burrett <nick@dsvr.net>

r0 RN 0
r1 RN 1
r2 RN 2
r3 RN 3
r4 RN 4
r5 RN 5
r6 RN 6
sp RN 13
lr RN 14
pc RN 15


OS_GenerateError	EQU &2B
OS_Exit			EQU &11
OS_GetEnv		EQU &10

SharedCLibrary_LibInitAPCS_R	EQU &80681
SharedCLibrary_LibInitAPCS_32	EQU &80683
 
	IMPORT	|Image$$RO$$Base|
	IMPORT	|RTSK$$Data$$Base|
	IMPORT	|RTSK$$Data$$Limit|
	IMPORT	|Image$$RW$$Base|
	IMPORT	|Image$$RW$$Limit|
	IMPORT	|Image$$ZI$$Base|
	IMPORT	|__root_stack_size|, WEAK
	IMPORT	|C$$code$$Base|
	IMPORT	|C$$code$$Limit|
	IMPORT	main, WEAK

	EXPORT	|__main|
	EXPORT	|_kernel_init|
	EXPORT	|_kernel_exit|
	EXPORT	|_kernel_setreturncode|
	EXPORT	|_kernel_exittraphandler|
	EXPORT	|_kernel_unwind|
	EXPORT	|_kernel_procname|
	EXPORT	|_kernel_language|
	EXPORT	|_kernel_command_string|
	EXPORT	|_kernel_hostos|
	EXPORT	|_kernel_swi|
	EXPORT	|_kernel_osbyte|
	EXPORT	|_kernel_osrdch|
	EXPORT	|_kernel_oswrch|
	EXPORT	|_kernel_osbget|
	EXPORT	|_kernel_osbput|
	EXPORT	|_kernel_osgbpb|
	EXPORT	|_kernel_osword|
	EXPORT	|_kernel_osfind|
	EXPORT	|_kernel_osfile|
	EXPORT	|_kernel_osargs|
	EXPORT	|_kernel_oscli|
	EXPORT	|_kernel_last_oserror|
	EXPORT	|_kernel_system|
	EXPORT	|_kernel_getenv|
	EXPORT	|_kernel_setenv|
	EXPORT	|_kernel_register_allocs|
	EXPORT	|_kernel_alloc|
	EXPORT	|_kernel_stkovf_split_0frame|
	EXPORT	|_kernel_stkovf_split|
	EXPORT	|_kernel_stkovf_copyargs|
	EXPORT	|_kernel_stkovf_copy0args|
	EXPORT	|_kernel_udiv|
	EXPORT	|__rt_udiv|
	EXPORT	|_kernel_urem|
	EXPORT	|_kernel_udiv10|
	EXPORT	|__rt_udiv10|
	EXPORT	|_kernel_sdiv|
	EXPORT	|__rt_sdiv|
	EXPORT	|_kernel_srem|
	EXPORT	|_kernel_sdiv10|
	EXPORT	|__rt_sdiv10|
	EXPORT	|_kernel_fpavailable|
	EXPORT	|_kernel_moduleinit|
	EXPORT	|_kernel_irqs_on|
	EXPORT	|_kernel_irqs_off|
	EXPORT	|_kernel_irqs_disabled|
	EXPORT	|_kernel_entermodule|
	EXPORT	|_kernel_escape_seen|
	EXPORT	|_kernel_current_stack_chunk|
	EXPORT	|_kernel_swi_c|
	EXPORT	|_kernel_register_slotextend|
	EXPORT	|_kernel_raise_error|

	EXPORT	TrapHandler
	EXPORT	UncaughtTrapHandler
	EXPORT	EventHandler
	EXPORT	UnhandledEventHandler
	EXPORT	|x$stack_overflow|
	EXPORT	|__rt_stkovf_split_small|
	EXPORT	|x$stack_overflow_1|
	EXPORT	|__rt_stkovf_split_big|
	EXPORT	|x$udivide|
	EXPORT	|x$uremainder|
	EXPORT	|x$divide|
	EXPORT	|x$divtest|
	EXPORT	|__rt_divtest|
	EXPORT	|x$remainder|
	EXPORT	|x$multiply|
	EXPORT	|_rd1chk|
	EXPORT	|_rd2chk|
	EXPORT	|_rd4chk|
	EXPORT	|_wr1chk|
	EXPORT	|_wr2chk|
	EXPORT	|_wr4chk|
	EXPORT	|_main|
	EXPORT	|_exit|
	EXPORT	|_clib_initialise|
	EXPORT	|_backtrace|
	EXPORT	|_count|
	EXPORT	|_count1|
	EXPORT	|_stfp|
	EXPORT	|_ldfp|
	EXPORT	|_printf|
	EXPORT	|_fprintf|
	EXPORT	|_sprintf|
	EXPORT	clock
	EXPORT	difftime
	EXPORT	mktime
	EXPORT	time
	EXPORT	asctime
	EXPORT	ctime
	EXPORT	gmtime
	EXPORT	localtime
	EXPORT	strftime
	EXPORT	memcpy
	EXPORT	memmove
	EXPORT	strcpy
	EXPORT	strncpy
	EXPORT	strcat
	EXPORT	strncat
	EXPORT	memcmp
	EXPORT	strcmp
	EXPORT	strncmp
	EXPORT	memchr
	EXPORT	strchr
	EXPORT	strcspn
	EXPORT	strpbrk
	EXPORT	strrchr
	EXPORT	strspn
	EXPORT	strstr
	EXPORT	strtok
	EXPORT	memset
	EXPORT	strerror
	EXPORT	strlen
	EXPORT	atof
	EXPORT	atoi
	EXPORT	atol
	EXPORT	strtod
	EXPORT	strtol
	EXPORT	strtoul
	EXPORT	rand
	EXPORT	srand
	EXPORT	calloc
	EXPORT	free
	EXPORT	malloc
	EXPORT	realloc
	EXPORT	abort
	EXPORT	atexit
	EXPORT	exit
	EXPORT	getenv
	EXPORT	system
	EXPORT	bsearch
	EXPORT	qsort
	EXPORT	abs
	EXPORT	div
	EXPORT	labs
	EXPORT	ldiv
	EXPORT	remove
	EXPORT	rename
	EXPORT	tmpfile
	EXPORT	|__old_tmpnam|
	EXPORT	fclose
	EXPORT	fflush
	EXPORT	fopen
	EXPORT	freopen
	EXPORT	setbuf
	EXPORT	setvbuf
	EXPORT	printf
	EXPORT	fprintf
	EXPORT	sprintf
	EXPORT	scanf
	EXPORT	fscanf
	EXPORT	sscanf
	EXPORT	vprintf
	EXPORT	|__gcc_vprintf|
	EXPORT	vfprintf
	EXPORT	|__gcc_vfprintf|
	EXPORT	vsprintf
	EXPORT	|__gcc_vsprintf|
	EXPORT	|_vfprintf|
	EXPORT	fgetc
	EXPORT	fgets
	EXPORT	fputc
	EXPORT	fputs
	EXPORT	|__filbuf|
	EXPORT	getc
	EXPORT	getchar
	EXPORT	gets
	EXPORT	|__flsbuf|
	EXPORT	putc
	EXPORT	putchar
	EXPORT	puts
	EXPORT	ungetc
	EXPORT	fread
	EXPORT	fwrite
	EXPORT	fgetpos
	EXPORT	fseek
	EXPORT	fsetpos
	EXPORT	ftell
	EXPORT	rewind
	EXPORT	clearerr
	EXPORT	feof
	EXPORT	ferror
	EXPORT	perror
	EXPORT	|__ignore_signal_handler|
	EXPORT	|__default_signal_handler|
	EXPORT	|__error_signal_marker|
	EXPORT	signal
	EXPORT	raise
	EXPORT	setjmp
	EXPORT	longjmp
	EXPORT	acos
	EXPORT	asin
	EXPORT	atan
	EXPORT	atan2
	EXPORT	cos
	EXPORT	sin
	EXPORT	tan
	EXPORT	cosh
	EXPORT	sinh
	EXPORT	tanh
	EXPORT	exp
	EXPORT	frexp
	EXPORT	ldexp
	EXPORT	log
	EXPORT	log10
	EXPORT	modf
	EXPORT	pow
	EXPORT	sqrt
	EXPORT	ceil
	EXPORT	fabs
	EXPORT	floor
	EXPORT	fmod
	EXPORT	setlocale
	EXPORT	isalnum
	EXPORT	isalpha
	EXPORT	iscntrl
	EXPORT	isdigit
	EXPORT	isgraph
	EXPORT	islower
	EXPORT	isprint
	EXPORT	ispunct
	EXPORT	isspace
	EXPORT	isupper
	EXPORT	isxdigit
	EXPORT	tolower
	EXPORT	toupper
	EXPORT	|__assert|
	EXPORT	|_memcpy|
	EXPORT	|_memset|
	EXPORT	localeconv
	EXPORT	mblen
	EXPORT	mbtowc
	EXPORT	wctomb
	EXPORT	mbstowcs
	EXPORT	wcstombs
	EXPORT	strxfrm
	EXPORT	strcoll
	EXPORT	|_clib_finalisemodule|
	EXPORT	|_clib_version|
	EXPORT	|_clib_finalise|  ; RISC OS PRMs say 'Finalise' but that'll clash
	EXPORT	tmpnam
	EXPORT	|_swi|
	EXPORT	|_swix|
	EXPORT  |disable_stack_extension|
	EXPORT	|__errno|
	EXPORT	errno
	EXPORT	|__iob|
	EXPORT	|_interrupts_off|
	EXPORT	|__ctype|
	EXPORT	|__huge_val|

	AREA	|Stub$$code|, CODE, READONLY

	ENTRY

	SWI	OS_GetEnv
	MOV	r2, r1			; workspace limit
	ADR	r0, stubs		; list of stubs
	LDR	r1, workspace		; workspace start
	MOV	r3, #-1			; "-1"
	MOV	r4, #0			; "0"
	MOV	r5, #-1			; "-1"

	; check for __root_stack_size. If it doesn't exist, then
	; make our own up.
	LDR	r6, stack_size
	TEQ	r6, #0
	LDRNE	r6, [r6]		; use __root_stack_size
	MOVEQ	r6, #(4*1024)		; 4KB (single chunk) stack, then.
	MOV	r6, r6, asr #10 	; convert bytes to KB
	MOV	r6, r6, lsl #16 	; put in upper 16bits

	[ {config} = 26
	SWI	SharedCLibrary_LibInitAPCS_R
	MOV	r6, r6, lsl #16 	; safety catch for ancient Shared C Lib modules
	CMP	r6, #(5<<16)		; check library version number
	|
	SWI	SharedCLibrary_LibInitAPCS_32
	MOV	r6, r6, lsl #16 	; safety catch for ancient Shared C Lib modules
	CMP	r6, #(6<<16)		; check library version number (32bit)
	]

	MOVGE	r4, r0			; end of workspace
	ADRGE	r0, kernel_init_block
	MOVGE	r3, #0			; we're an application
	BGE	|_kernel_init|		; off we go!

	ADR	r0, error
	SWI	OS_GenerateError
error
	DCD	0
	DCB	"Shared C Library not loaded or out of date", 0
	ALIGN

stubs
	DCD	1			; lib chunk id : kernel
	DCD	kernel_vectors
	DCD	kernel_vectors_end
	DCD	kernel_statics
	DCD	kernel_statics_end
	DCD	2			; lib chunk id : CLib
	DCD	clib_vectors
	DCD	clib_vectors_end
	DCD	clib_statics
	DCD	clib_statics_end
	DCD	-1			; end of list

kernel_init_block
	DCD	|Image$$RO$$Base|	; image base
	DCD	|RTSK$$Data$$Base|	; start of lang blocks
	DCD	|RTSK$$Data$$Limit|	; end of lang blocks
workspace
	DCD	|Image$$RW$$Limit|
stack_size
	DCD	|__root_stack_size|
	DCD	|Image$$RW$$Base|
	DCD	|Image$$ZI$$Base|



	AREA	|RTSK$$Data|, DATA, READONLY
	DCD	40 ; |RTSK$$Data$$Limit| - |RTSK$$Data$$Base|
	DCD	|C$$code$$Base|
	DCD	|C$$code$$Limit|
	DCD	language_name		; must be "C"
	DCD	|__main|		; our PROC-returning InitProc
	DCD	0			; finaliser
	; these are the "optionals"...
	DCD	|TrapHandler|		; SharedCLib's own trap handler...
	DCD	|UncaughtTrapHandler|	; ...and uncaught trap proc
	DCD	|EventHandler|		; ...and event proc
	DCD	|UnhandledEventHandler|	; ...and unhandled event proc!
	; no fast event proc
	; no unwind proc
	; no name proc

	AREA	|C$$Code|, CODE, READONLY
language_name
	DCB	"C", 0
	ALIGN

|__main|
	MOV	r0, #1
	LDR	r1, stub_data
	STRB	r0, [r1, #_stub_kallocExtendsWS - kernel_statics]

	MOV	r0, sp			; (historical??)
	STMFD	sp!, {lr}
	LDR	r1, rtsk_data
	LDMIB	r1, {r1, r2}		; fetch code start/end (historical??)
	BL	|_clib_initialise|
	LDR	r0, c_run		; get our main()
	CMP	r0, #0			; was there one?
	ADRNE	r0, c_next		; yup, so point to hook to it
	LDMFD	sp!, {pc}^

; this is called when all RTL blocks have been initialised via their InitProc
c_next
	STMFD	sp!, {lr}		
	BL	|_kernel_command_string|; get r0=command string
	LDMFD	sp!, {lr}
	LDR	r1, c_run		; get ptr to main() function
	B	|_main|			; call clib to enter it.  Never returns from here.

stub_data
	DCD	|Stub$$Data|

rtsk_data
	DCD	|RTSK$$Data|

c_run
	DCD	main

	AREA	|Stub$$Entries|, DATA
kernel_vectors
	%	48 * 4
kernel_vectors_end

clib_vectors
	%	185 * 4
clib_vectors_end

|_kernel_init|			EQU	kernel_vectors
|_kernel_exit|			EQU	kernel_vectors+(1*4)
|_kernel_setreturncode|		EQU	kernel_vectors+(2*4)
|_kernel_exittraphandler|	EQU	kernel_vectors+(3*4)
|_kernel_unwind|		EQU	kernel_vectors+(4*4)
|_kernel_procname|		EQU	kernel_vectors+(5*4)
|_kernel_language|		EQU	kernel_vectors+(6*4)
|_kernel_command_string|	EQU	kernel_vectors+(7*4)
|_kernel_hostos|		EQU	kernel_vectors+(8*4)
|_kernel_swi|			EQU	kernel_vectors+(9*4)
|_kernel_osbyte|		EQU	kernel_vectors+(10*4)
|_kernel_osrdch|		EQU	kernel_vectors+(11*4)
|_kernel_oswrch|		EQU	kernel_vectors+(12*4)
|_kernel_osbget|		EQU	kernel_vectors+(13*4)
|_kernel_osbput|		EQU	kernel_vectors+(14*4)
|_kernel_osgbpb|		EQU	kernel_vectors+(15*4)
|_kernel_osword|		EQU	kernel_vectors+(16*4)
|_kernel_osfind|		EQU	kernel_vectors+(17*4)
|_kernel_osfile|		EQU	kernel_vectors+(18*4)
|_kernel_osargs|		EQU	kernel_vectors+(19*4)
|_kernel_oscli|			EQU	kernel_vectors+(20*4)
|_kernel_last_oserror|		EQU	kernel_vectors+(21*4)
|_kernel_system|		EQU	kernel_vectors+(22*4)
|_kernel_getenv|		EQU	kernel_vectors+(23*4)
|_kernel_setenv|		EQU	kernel_vectors+(24*4)
|_kernel_register_allocs|	EQU	kernel_vectors+(25*4)
|_kernel_alloc|			EQU	kernel_vectors+(26*4)
|_kernel_stkovf_split_0frame|	EQU	kernel_vectors+(27*4)
|_kernel_stkovf_split|		EQU	kernel_vectors+(28*4)
|_kernel_stkovf_copyargs|	EQU	kernel_vectors+(29*4)
|_kernel_stkovf_copy0args|	EQU	kernel_vectors+(30*4)
|_kernel_udiv|			EQU	kernel_vectors+(31*4)
|__rt_udiv|			EQU	kernel_vectors+(31*4)
|_kernel_urem|			EQU	kernel_vectors+(32*4)
|_kernel_udiv10|		EQU	kernel_vectors+(33*4)
|__rt_udiv10|			EQU	kernel_vectors+(33*4)
|_kernel_sdiv|			EQU	kernel_vectors+(34*4)
|__rt_sdiv|			EQU	kernel_vectors+(34*4)
|_kernel_srem|			EQU	kernel_vectors+(35*4)
|_kernel_sdiv10|		EQU	kernel_vectors+(36*4)
|__rt_sdiv10|			EQU	kernel_vectors+(36*4)
|_kernel_fpavailable|		EQU	kernel_vectors+(37*4)
|_kernel_moduleinit|		EQU	kernel_vectors+(38*4)
|_kernel_irqs_on|		EQU	kernel_vectors+(39*4)
|_kernel_irqs_off|		EQU	kernel_vectors+(40*4)
|_kernel_irqs_disabled|		EQU	kernel_vectors+(41*4)
|_kernel_entermodule|		EQU	kernel_vectors+(42*4)
|_kernel_escape_seen|		EQU	kernel_vectors+(43*4)
|_kernel_current_stack_chunk|	EQU	kernel_vectors+(44*4)
|_kernel_swi_c|			EQU	kernel_vectors+(45*4)
|_kernel_register_slotextend|	EQU	kernel_vectors+(46*4)
|_kernel_raise_error|		EQU	kernel_vectors+(47*4)

|TrapHandler|			EQU	clib_vectors
|UncaughtTrapHandler|		EQU	clib_vectors+(1*4)
|EventHandler|			EQU	clib_vectors+(2*4)
|UnhandledEventHandler|		EQU	clib_vectors+(3*4)
|x$stack_overflow|		EQU	clib_vectors+(4*4)
|__rt_stkovf_split_small|	EQU	clib_vectors+(4*4)
|x$stack_overflow_1|		EQU	clib_vectors+(5*4)
|__rt_stkovf_split_big|		EQU	clib_vectors+(5*4)
|x$udivide|			EQU	clib_vectors+(6*4)
|x$uremainder|			EQU	clib_vectors+(7*4)
|x$divide|			EQU	clib_vectors+(8*4)
|x$divtest|			EQU	clib_vectors+(9*4)
|__rt_divtest|			EQU	clib_vectors+(9*4)
|x$remainder|			EQU	clib_vectors+(10*4)
|x$multiply|			EQU	clib_vectors+(11*4)
|_rd1chk|			EQU	clib_vectors+(12*4)
|_rd2chk|			EQU	clib_vectors+(13*4)
|_rd4chk|			EQU	clib_vectors+(14*4)
|_wr1chk|			EQU	clib_vectors+(15*4)
|_wr2chk|			EQU	clib_vectors+(16*4)
|_wr4chk|			EQU	clib_vectors+(17*4)
|_main|				EQU	clib_vectors+(18*4)
|_exit|				EQU	clib_vectors+(19*4)
|_clib_initialise|		EQU	clib_vectors+(20*4)
|_backtrace|			EQU	clib_vectors+(21*4)
|_count|			EQU	clib_vectors+(22*4)
|_count1|			EQU	clib_vectors+(23*4)
|_stfp|				EQU	clib_vectors+(24*4)
|_ldfp|				EQU	clib_vectors+(25*4)
|_printf|			EQU	clib_vectors+(26*4)
|_fprintf|			EQU	clib_vectors+(27*4)
|_sprintf|			EQU	clib_vectors+(28*4)
|clock|				EQU	clib_vectors+(29*4)
|difftime|			EQU	clib_vectors+(30*4)
|mktime|			EQU	clib_vectors+(31*4)
|time|				EQU	clib_vectors+(32*4)
|asctime|			EQU	clib_vectors+(33*4)
|ctime|				EQU	clib_vectors+(34*4)
|gmtime|			EQU	clib_vectors+(35*4)
|localtime|			EQU	clib_vectors+(36*4)
|strftime|			EQU	clib_vectors+(37*4)
|memcpy|			EQU	clib_vectors+(38*4)
|memmove|			EQU	clib_vectors+(39*4)
|strcpy|			EQU	clib_vectors+(40*4)
|strncpy|			EQU	clib_vectors+(41*4)
|strcat|			EQU	clib_vectors+(42*4)
|strncat|			EQU	clib_vectors+(43*4)
|memcmp|			EQU	clib_vectors+(44*4)
|strcmp|			EQU	clib_vectors+(45*4)
|strncmp|			EQU	clib_vectors+(46*4)
|memchr|			EQU	clib_vectors+(47*4)
|strchr|			EQU	clib_vectors+(48*4)
|strcspn|			EQU	clib_vectors+(49*4)
|strpbrk|			EQU	clib_vectors+(50*4)
|strrchr|			EQU	clib_vectors+(51*4)
|strspn|			EQU	clib_vectors+(52*4)
|strstr|			EQU	clib_vectors+(53*4)
|strtok|			EQU	clib_vectors+(54*4)
|memset|			EQU	clib_vectors+(55*4)
|strerror|			EQU	clib_vectors+(56*4)
|strlen|			EQU	clib_vectors+(57*4)
|atof|				EQU	clib_vectors+(58*4)
|atoi|				EQU	clib_vectors+(59*4)
|atol|				EQU	clib_vectors+(60*4)
|strtod|			EQU	clib_vectors+(61*4)
|strtol|			EQU	clib_vectors+(62*4)
|strtoul|			EQU	clib_vectors+(63*4)
|rand|				EQU	clib_vectors+(64*4)
|srand|				EQU	clib_vectors+(65*4)
|calloc|			EQU	clib_vectors+(66*4)
|free|				EQU	clib_vectors+(67*4)
|malloc|			EQU	clib_vectors+(68*4)
|realloc|			EQU	clib_vectors+(69*4)
|abort|				EQU	clib_vectors+(70*4)
|atexit|			EQU	clib_vectors+(71*4)
|exit|				EQU	clib_vectors+(72*4)
|getenv|			EQU	clib_vectors+(73*4)
|system|			EQU	clib_vectors+(74*4)
|bsearch|			EQU	clib_vectors+(75*4)
|qsort|				EQU	clib_vectors+(76*4)
|abs|				EQU	clib_vectors+(77*4)
|div|				EQU	clib_vectors+(78*4)
|labs|				EQU	clib_vectors+(79*4)
|ldiv|				EQU	clib_vectors+(80*4)
|remove|			EQU	clib_vectors+(81*4)
|rename|			EQU	clib_vectors+(82*4)
|tmpfile|			EQU	clib_vectors+(83*4)
|__old_tmpnam|			EQU	clib_vectors+(84*4)
|fclose|			EQU	clib_vectors+(85*4)
|fflush|			EQU	clib_vectors+(86*4)
|fopen|				EQU	clib_vectors+(87*4)
|freopen|			EQU	clib_vectors+(88*4)
|setbuf|			EQU	clib_vectors+(89*4)
|setvbuf|			EQU	clib_vectors+(90*4)
|printf|			EQU	clib_vectors+(91*4)
|fprintf|			EQU	clib_vectors+(92*4)
|sprintf|			EQU	clib_vectors+(93*4)
|scanf|				EQU	clib_vectors+(94*4)
|fscanf|			EQU	clib_vectors+(95*4)
|sscanf|			EQU	clib_vectors+(96*4)
|vprintf|			EQU	clib_vectors+(97*4)
|__gcc_vprintf|			EQU	clib_vectors+(97*4)
|vfprintf|			EQU	clib_vectors+(98*4)
|__gcc_vfprintf|		EQU	clib_vectors+(98*4)
|vsprintf|			EQU	clib_vectors+(99*4)
|__gcc_vsprintf|		EQU	clib_vectors+(99*4)
|_vfprintf|			EQU	clib_vectors+(100*4)
|fgetc|				EQU	clib_vectors+(101*4)
|fgets|				EQU	clib_vectors+(102*4)
|fputc|				EQU	clib_vectors+(103*4)
|fputs|				EQU	clib_vectors+(104*4)
|__filbuf|			EQU	clib_vectors+(105*4)
|getc|				EQU	clib_vectors+(106*4)
|getchar|			EQU	clib_vectors+(107*4)
|gets|				EQU	clib_vectors+(108*4)
|__flsbuf|			EQU	clib_vectors+(109*4)
|putc|				EQU	clib_vectors+(110*4)
|putchar|			EQU	clib_vectors+(111*4)
|puts|				EQU	clib_vectors+(112*4)
|ungetc|			EQU	clib_vectors+(113*4)
|fread|				EQU	clib_vectors+(114*4)
|fwrite|			EQU	clib_vectors+(115*4)
|fgetpos|			EQU	clib_vectors+(116*4)
|fseek|				EQU	clib_vectors+(117*4)
|fsetpos|			EQU	clib_vectors+(118*4)
|ftell|				EQU	clib_vectors+(119*4)
|rewind|			EQU	clib_vectors+(120*4)
|clearerr|			EQU	clib_vectors+(121*4)
|feof|				EQU	clib_vectors+(122*4)
|ferror|			EQU	clib_vectors+(123*4)
|perror|			EQU	clib_vectors+(124*4)
|__ignore_signal_handler|	EQU	clib_vectors+(125*4)
|__error_signal_marker|		EQU	clib_vectors+(126*4)
|__default_signal_handler|	EQU	clib_vectors+(127*4)
|signal|			EQU	clib_vectors+(128*4)
|raise|				EQU	clib_vectors+(129*4)
|setjmp|			EQU	clib_vectors+(130*4)
|longjmp|			EQU	clib_vectors+(131*4)
|acos|				EQU	clib_vectors+(132*4)
|asin|				EQU	clib_vectors+(133*4)
|atan|				EQU	clib_vectors+(134*4)
|atan2|				EQU	clib_vectors+(135*4)
|cos|				EQU	clib_vectors+(136*4)
|sin|				EQU	clib_vectors+(137*4)
|tan|				EQU	clib_vectors+(138*4)
|cosh|				EQU	clib_vectors+(139*4)
|sinh|				EQU	clib_vectors+(140*4)
|tanh|				EQU	clib_vectors+(141*4)
|exp|				EQU	clib_vectors+(142*4)
|frexp|				EQU	clib_vectors+(143*4)
|ldexp|				EQU	clib_vectors+(144*4)
|log|				EQU	clib_vectors+(145*4)
|log10|				EQU	clib_vectors+(146*4)
|modf|				EQU	clib_vectors+(147*4)
|pow|				EQU	clib_vectors+(148*4)
|sqrt|				EQU	clib_vectors+(149*4)
|ceil|				EQU	clib_vectors+(150*4)
|fabs|				EQU	clib_vectors+(151*4)
|floor|				EQU	clib_vectors+(152*4)
|fmod|				EQU	clib_vectors+(153*4)
|setlocale|			EQU	clib_vectors+(154*4)
|isalnum|			EQU	clib_vectors+(155*4)
|isalpha|			EQU	clib_vectors+(156*4)
|iscntrl|			EQU	clib_vectors+(157*4)
|isdigit|			EQU	clib_vectors+(158*4)
|isgraph|			EQU	clib_vectors+(159*4)
|islower|			EQU	clib_vectors+(160*4)
|isprint|			EQU	clib_vectors+(161*4)
|ispunct|			EQU	clib_vectors+(162*4)
|isspace|			EQU	clib_vectors+(163*4)
|isupper|			EQU	clib_vectors+(164*4)
|isxdigit|			EQU	clib_vectors+(165*4)
|tolower|			EQU	clib_vectors+(166*4)
|toupper|			EQU	clib_vectors+(167*4)
|__assert|			EQU	clib_vectors+(168*4)
|_memcpy|			EQU	clib_vectors+(169*4)
|_memset|			EQU	clib_vectors+(170*4)
|localeconv|			EQU	clib_vectors+(171*4)
|mblen|				EQU	clib_vectors+(172*4)
|mbtowc|			EQU	clib_vectors+(173*4)
|wctomb|			EQU	clib_vectors+(174*4)
|mbstowcs|			EQU	clib_vectors+(175*4)
|wcstombs|			EQU	clib_vectors+(176*4)
|strxfrm|			EQU	clib_vectors+(177*4)
|strcoll|			EQU	clib_vectors+(178*4)
|_clib_finalisemodule|		EQU	clib_vectors+(179*4)
|_clib_version|			EQU	clib_vectors+(180*4)
|_clib_finalise|		EQU	clib_vectors+(181*4)
|tmpnam|			EQU	clib_vectors+(182*4)
|_swi|				EQU	clib_vectors+(183*4)
|_swix|				EQU	clib_vectors+(184*4)



	AREA	|Stub$$Data|, DATA
kernel_statics	% &31c
kernel_statics_end

|_stub_imageBase|		EQU	kernel_statics+&000
|_stub_rtsDataBase|		EQU	kernel_statics+&004
|_stub_rtsDataLimit|		EQU	kernel_statics+&008
|_stub_errorR12|		EQU	kernel_statics+&00c
|_stub_errorBuffer|		EQU	kernel_statics+&010
|_stub_errorNumber|		EQU	kernel_statics+&014
|_stub_errorString|		EQU	kernel_statics+&018
|_stub_registerDump|		EQU	kernel_statics+&07c
|_stub_oldAbortHandlers| 	EQU	kernel_statics+&0bc
|_stub_oldExitHandler|		EQU	kernel_statics+&0cc
|_stub_oldMemoryLimit|		EQU	kernel_statics+&0d4
|_stub_oldErrorHandler|  	EQU	kernel_statics+&0d8
|_stub_oldErrorR0|		EQU	kernel_statics+&0dc
|_stub_oldErrorBuffer|		EQU	kernel_statics+&0e0
|_stub_oldCallBackHandler|	EQU	kernel_statics+&0e4
|_stub_oldEscapeHandler|	EQU	kernel_statics+&0f0
|_stub_oldEventHandler|  	EQU	kernel_statics+&0f8
|_stub_oldUpCallHandler| 	EQU	kernel_statics+&100
|_stub_languageEnvSave|  	EQU	kernel_statics+&108
|_stub_hadEscape|		EQU	kernel_statics+&114
|_stub_kallocExtendsWS|  	EQU	kernel_statics+&115
|_stub_inTrapHandler|		EQU	kernel_statics+&116
|_stub_beingDebugged|		EQU	kernel_statics+&117
|_stub_fpPresent|		EQU	kernel_statics+&118
|_stub_initialised|		EQU	kernel_statics+&119
|_stub_callbackInactive| 	EQU	kernel_statics+&11a
|_stub_unused_byte_2|		EQU	kernel_statics+&11b
|_stub_IIHandlerInData|  	EQU	kernel_statics+&11c
|_stub_PAHandlerInData|  	EQU	kernel_statics+&128
|_stub_DAHandlerInData|  	EQU	kernel_statics+&134
|_stub_AEHandlerInData|  	EQU	kernel_statics+&140
|_stub_eventCode|		EQU	kernel_statics+&14c
|_stub_eventUserR13|		EQU	kernel_statics+&150
|_stub_eventRegisters|		EQU	kernel_statics+&154
|_stub_fastEventStack|		EQU	kernel_statics+&184
|_stub_fastEventStackEnd|	EQU	kernel_statics+&284
|_stub_heapTop| 		EQU	kernel_statics+&284
|_stub_heapLimit|		EQU	kernel_statics+&288
|_stub_allocProc|		EQU	kernel_statics+&28c
|_stub_freeProc| 		EQU	kernel_statics+&290
|_stub_returnCode|		EQU	kernel_statics+&294
|_stub_moduleDataWord|		EQU	kernel_statics+&298
|_stub_APCS_A_Client|		EQU	kernel_statics+&29c
|_stub_escapeSeen|		EQU	kernel_statics+&29d
|_stub_unwinding|		EQU	kernel_statics+&29e
|_stub_underDesktop|		EQU	kernel_statics+&29f
|_stub_heapBase|		EQU	kernel_statics+&2a0
|_stub_ArgString|		EQU	kernel_statics+&2a4
|_stub_heapExtender|		EQU	kernel_statics+&2a8
|_stub_knownSlotSize|		EQU	kernel_statics+&2ac
|_stub_initSlotSize|		EQU	kernel_statics+&2b0
|_stub_lk_RestoreOSHandlers|	EQU	kernel_statics+&2b4
|_stub_extendChunk|		EQU	kernel_statics+&2b8
|_stub_rootStackChunk|		EQU	kernel_statics+&2bc
|_stub_pc_hex_buff|		EQU	kernel_statics+&2c0
|_stub_returnCodeLimit|		EQU	kernel_statics+&2c0
|_stub_reg_hex_buff|		EQU	kernel_statics+&2cc
|disable_stack_extension|	EQU	kernel_statics+&2d8
|_stub_unused|			EQU	kernel_statics+&2dc

clib_statics	% &b48
clib_statics_end

errno				EQU	clib_statics+0
|__errno|			EQU	clib_statics+0
|__iob|				EQU	clib_statics+4
|_interrupts_off|		EQU	clib_statics+&284
|_stub__saved_interrupt|	EQU	clib_statics+&288
|_stub_ctype_eof|		EQU	clib_statics+&28C
|__ctype|			EQU	clib_statics+&290
|__huge_val|			EQU	clib_statics+&390

|_stub_app_space_end|		EQU	clib_statics+&6b4
|_stub_stack_o_flag|		EQU	clib_statics+&6b8
|_stub_inSignalHandler|		EQU	clib_statics+&6b9
|_stub_dummybyte|		EQU	clib_statics+&6ba
|_stub_|			EQU	clib_statics+&6bb
|_stub_ClibSpace|		EQU	clib_statics+&6bc

	END
