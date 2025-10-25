; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

; =====================================================================================================================
; = 
; =====================================================================================================================

STRUCT ksym_entry_t
	.address		resq	1
	.meta			resq	1
ENDSTRUCT

STRUCT ksym_meta_entry_t
	.fname		resq	1
	.fsize		resq	1
ENDSTRUCT

; =====================================================================================================================
; = 
; =====================================================================================================================

FUNCTION _ksym_sort

	extern __kernel_symbols_start
	extern __kernel_symbols_end

	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	r8
	push	r9
	push	r10
	push	r14
	push	r15

	mov		rsi, __kernel_symbols_start
	mov		rcx, __kernel_symbols_end
	sub		rcx, rsi
	shr		rcx, 4

	cmp		rcx, 2
	jb		.return

	mov     rbx, 1
.outer_loop:
	cmp     rbx, rcx
	jae     .return

	imul	r14, rbx, ksym_entry_t.size

	mov     r9, [rsi + r14 + ksym_entry_t.address]
	mov     r10, [rsi + r14 + ksym_entry_t.meta]

	lea     r8, [rbx - 1]
.inner_loop:
	imul	r15, r8, ksym_entry_t.size
	mov     rax, [rsi + r15 + ksym_entry_t.address]

	cmp     rax, r9
	jbe     .insert_here

	mov     rdx, [rsi + r15 + ksym_entry_t.address]
	mov     [rsi + r15 + ksym_entry_t.size + ksym_entry_t.address], rdx
	mov     rdx, [rsi + r15 + ksym_entry_t.meta]
	mov     [rsi + r15 + ksym_entry_t.size + ksym_entry_t.meta], rdx

	dec     r8
	js      .at_begin
	jmp     .inner_loop

.at_begin:
	mov     r8, -1

.insert_here:
	imul	r15, r8, ksym_entry_t.size
	mov     [rsi + r15 + ksym_entry_t.size + ksym_entry_t.address], r9
	mov     [rsi + r15 + ksym_entry_t.size + ksym_entry_t.meta], r10

	inc     rbx
	jmp     .outer_loop

.return:
	mov 	rax, rcx

	pop		r15
	pop		r14
	pop		r10
	pop		r9
	pop		r8
	pop		rsi
	pop		rdx
	pop		rcx
	pop		rbx
	ret

ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

FUNCTION _ksym_find

    extern __kernel_symbols_start
    extern __kernel_symbols_end

    push    rbx
    push    rdx
    push    rsi
    push    r8

    mov     rsi, __kernel_symbols_start
    mov     rcx, __kernel_symbols_end
    sub     rcx, rsi
    shr     rcx, 4
    test    rcx, rcx
    jz      .not_found

    xor     r8, r8

.loop:
    imul    rdx, r8, ksym_entry_t.size
    mov     rbx, [rsi + rdx + ksym_entry_t.address]
    cmp     rax, rbx
    jb      .not_found

    mov     rdx, [rsi + rdx + ksym_entry_t.meta]
	add		rbx, [rdx + ksym_meta_entry_t.fsize]
    cmp     rax, rbx
    jb      .found

.next:
    inc     r8
    loop    .loop

.not_found:
    xor     rax, rax
    jmp     .end

.found:
    mov     rax, rdx

.end:
    pop     r8
    pop     rsi
    pop     rdx
    pop     rbx
    ret

ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

FUNCTION _ksym_dump
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	r8
	push	r9
	push	r10
	push	r15

	BOCHS_MAGIC_BREAK

	mov		rsi, __kernel_symbols_start
	mov		rcx, __kernel_symbols_end
	sub		rcx, rsi
	shr		rcx, 4

	mov		rdx, 0
.next:
	cmp		rdx, rcx
	jae		.return

	mov		r15, [rsi + ksym_entry_t.meta]

	mov		r8, [rsi + ksym_entry_t.address]
	mov		r9, [r15 + ksym_meta_entry_t.fname]
	mov		r10, [r15 + ksym_meta_entry_t.fsize]

	extern vdebug_write_word
	extern vdebug_write_string

	push	rcx
	push	rsi

	mov		rax, r8
	mov		rcx, 16
	call	vdebug_write_word

	mov		rsi, txt_colon
	call	vdebug_write_string

	mov		rax, r10
	mov		rcx, 16
	call	vdebug_write_word

	extern txt_equal

	mov		rsi, txt_equal
	call	vdebug_write_string

	mov		rsi, r9
	call	vdebug_write_string

	extern txt_crlf

	mov		rsi, txt_crlf
	call	vdebug_write_string

	pop		rsi
	pop		rcx

	inc		rdx
	add		rsi, ksym_entry_t.size
	jmp		.next

.return:
	pop		r15
	pop		r10
	pop		r9
	pop		r8
	pop		rsi
	pop		rdx
	pop		rcx
	pop		rbx
	pop		rax
	ret

ENDFUNCTION

RODATA txt_colon
	db	': ', 0
