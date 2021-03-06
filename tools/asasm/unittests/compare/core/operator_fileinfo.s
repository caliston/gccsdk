; Basic tests for :FATTR:, :FLOAD:, :FEXEC: and :FSIZE:.

	; Use include/foo-3bytes.s which is known to be 3 bytes
	; long.
	ASSERT :FSIZE: "include/foo-3bytes.s" == 3

	; Use include/foo-filetypeAB3 which is has filetype
	; &AB3.
	ASSERT :FLOAD: "include/foo-filetypeAB3" >>> 8 == &FFFFFAB3

	; Test file attribute.  We assume we have at least owner read/write
	; access.
	ASSERT :FATTR: "include/foo-3bytes.s" :AND: 3 == 3
	
	END
