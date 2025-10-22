; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

; =====================================================================================================================
; = vdebug_write_char =================================================================================================
; =====================================================================================================================
;
;   In:     al      ascii char to be written to VM debug port
;
;   Out:    /
;

FUNCTION vdebug_write_char
	out BOCHS_HACK_PORT, al
	ret

; =====================================================================================================================
; = vdebug_write_string ===============================================================================================
; =====================================================================================================================
;
;   In:     rsi     address of the asciiz string to be written to VM debug port
;
;   Out:    /
;

FUNCTION vdebug_write_string
	pushf
	push    rax
	push    rsi

	cld

 .loop:
	lodsb
	test    al, al
	jz      .return

	call    vdebug_write_char
	jmp     .loop

.return:
	pop     rsi
	pop     rax
	popf
	ret

; =====================================================================================================================
; = vdebug_write_xdigit ===============================================================================================
; =====================================================================================================================
;
;   In:     al      digit to be written (in hexadecimal) to VM debug port
;
;   Out:    /
;

FUNCTION vdebug_write_xdigit
	push    rax
	push    rbx

	mov     rbx, vdebug_hex_table

	and     al, 0x0F
	xlat
	call    vdebug_write_char

	pop     rbx
	pop     rax
	ret

RODATA vdebug_hex_table
	db      "0123456789ABCDEF"

; =====================================================================================================================
; = 
; =====================================================================================================================
;
;   In:     rax     digit to be written (in hexadecimal) to VM debug port
;           cl      x
;
;   Out:    /
;

FUNCTION vdebug_write_word
	push    rcx

	and		rcx, rcx
	jz		.return

	cmp     rcx, 16
	jbe     .rcx_ok

	mov     rcx, 16

.rcx_ok:
	mov     ch, cl
	mov     cl, 16						;
	sub     cl, ch						; 
	jz      .full_print

	shl     cl, 2
	rol     rax, cl

.full_print:
	mov     cl, ch

.loop:
	rol     rax, 4

	call    vdebug_write_xdigit

	dec     cl
	jnz     .loop

.return:
	pop     rcx
	ret

FUNCTION vdebug_write_xword
	push    rax
	push    rbx

	push    rax
	shr     al, 8
	call    vdebug_write_xdigit

	pop     rax
	call    vdebug_write_xdigit

	pop     rbx
	pop     rax
	ret

FUNCTION vdebug_write_xdword
	push    rax
	push    rbx

	push    rax
	shr     al, 16
	call    vdebug_write_xword

	pop     rax
	call    vdebug_write_xword

	pop     rbx
	pop     rax
	ret

FUNCTION vdebug_write_xqword
	push    rax
	push    rbx

	push    rax
	shr     al, 32
	call    vdebug_write_xdword

	pop     rax
	call    vdebug_write_xdword

	pop     rbx
	pop     rax
	ret

FUNCTION vdebug_write_xtword
	push    rax
	push    rbx

	push    rax
	mov     rax, rdx
	call    vdebug_write_xqword

	pop     rax
	call    vdebug_write_xqword

	pop     rbx
	pop     rax
	ret
