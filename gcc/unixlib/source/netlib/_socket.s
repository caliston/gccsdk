;----------------------------------------------------------------------------
;
; $Source: /usr/local/cvsroot/unixlib/source/netlib/s/_socket,v $
; $Date: 2000/12/21 15:09:13 $
; $Revision: 1.7 $
; $State: Exp $
; $Author: admin $
;
;----------------------------------------------------------------------------

	GET	clib/unixlib/asm_dec.s

	AREA	|C$$code|,CODE,READONLY

	IMPORT	|__net_error_simple_entry|

	EXPORT	|_socket|
|_socket|
	NetSWIsimple	XSocket_Creat

	END
