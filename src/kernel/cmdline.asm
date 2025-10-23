; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     X64
	bits    64

	extern _strcmpz

; parse_cmdline_map_rsi_src:
; RSI=cmdline, RDI=out_pairs, RDX=out_capacity, RCX=registry, R8=registry_count
; -> RAX=count_out

;   rsi < command line
;   rdi < kvpair registry (terminated with .key = 0)

FUNCTION _parse_command_line
	push	rax
	push	rbx
	push	rsi
	push	r8
	push	r9
	push	r10
	push	r11
	push	r12

.next_item:

	; --- trim --------------------------------------------------------------------------------------------------------

.skip:
	mov		al, [rsi]

	test	al, al											; eos ?
	jz		.done

	cmp		al, ' '											; space ?
	jne		.go

	inc		rsi
 	jmp		.skip

	; --- find end of token (next space) ------------------------------------------------------------------------------

.go:
	mov		r8, rsi											; r8 = start of key

	xor		r9,  r9											; r9 position of '=' (none yet)
    xor		r10, r10										; r10 = in quote

.scan:
	mov		al, [rsi]

	test	al, al											; eos ?
	jz		.tok_end_null

	cmp		r10, 0											; in quote mode ?
	jne		.in_quote

	cmp		al, ' '											; space ?
	je		.tok_end_spc

	cmp		al, '='											; equal ?
    jne		.adv

	test	r9, r9											; already had equal ?
	jne		.adv

    lea		r9, [rsi]										; store position of '='

	mov		al, [rsi + 1]

	cmp		al, '"'											; quote ?
	jne		.adv

	mov		r10, 1											; enter quote mode
    add		rsi, 2											; skip equal and quote
    jmp		.scan

.in_quote:
	cmp		al, '"'											; quote ?
	jne		.adv

	mov		r10, 0											; exit quote mode

	cmp		byte [rsi + 1], ' '
	je		.no_patch_missing_space

	mov		byte [rsi], ' '									; handle edget case key="value"nospace by making it key="value nospace
	jmp		.scan

.no_patch_missing_space:
	inc		rsi
	jmp		.scan

.adv:
	inc		rsi
	jmp		.scan											; continue scan

.tok_end_spc:
	mov		byte [rsi], 0									; set end of token
    mov		r10, [rsi - 1]									; r10 = last character 

    inc		rsi
    jmp		.store

.tok_end_null:
    lea		r10, [rsi - 1]									; r10 = last character 

	; --- split and remove quotes -------------------------------------------------------------------------------------

.store:
	BOCHS_MAGIC_BREAK

	cmp		r9, 0											; has equal ?
    je		.apply											; no

	mov		byte [r9], 0									; split at equal
	inc		r9

    cmp		byte [r9], '"'									; initial quote ?
    jne		.apply

	inc		r9

    cmp		byte [r10], '"'									; final quote ?
    jne		.apply

    mov		byte [r10], 0

; at this point:
;	r8 = ptr to key
;	r9 = ptr to value or 0 if none

.apply:
	BOCHS_MAGIC_BREAK

	test	r9, r9											; no value  ?
	jnz		.check_key

	mov		r9, _value_1									; set to true (key alone treated as a flag)

.check_key:
	cmp		byte [r8], 0									; empty key ?
    je		.next_item

	mov		r10, rdi
	mov		r11, r8
.find:
	mov		r12, qword [r10 + kvpair.key]

	test	r12, r12
	jz		.next_item

.cmp_loop:
	mov		al, [r11]										; command line key
	mov		bl, [r12]										; command line key
	cmp		al, bl											; registry key
    jne		.cmp_ne

    add		al, bl
    jz		.cmp_eq

    inc		r11
    inc 	r12
    jmp		.cmp_loop

.cmp_ne:
	add		r10, kvpair.size
    jmp		.find

.cmp_eq:
	mov		[r10 + kvpair.value], r9
    jmp		.next_item

.done:
	pop	r12
	pop	r11
	pop	r10
	pop	r9
	pop	r8
	pop	rsi
	pop	rbx
	pop	rax
    ret

RODATA _value_1
	db	'1', 0