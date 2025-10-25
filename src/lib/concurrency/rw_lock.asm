; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

	%include "lib/concurrency_def.inc"

; =====================================================================================================================
; = 
; =====================================================================================================================

;   rsi < rw_lock address

FUNCTION _rw_write_lock
	push	rax

.spin:
	mov		eax, 1
	xchg	eax, [rsi + rw_lock.writer]   ; essaye de passer writer=1
	test	eax, eax
	jz		.wait_readers

    pause

    jmp		.spin

.wait_readers:
	cmp		dword [rdi + rw_lock.readers], 0
	je		.got

	pause

	jmp		.wait_readers

.got:
    pop     rax
    ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   rsi < rw_lock address

FUNCTION _rw_write_unlock
	mov		dword [rdi + rw_lock.writer], 0
	ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   rsi < rw_lock address

FUNCTION _rw_read_lock
.try:
	lock inc dword [rsi + rw_lock.readers]
	cmp		dword [rsi + rw_lock.writer], 0
	jne		.ok

	lock dec dword [rsi + rw_lock.readers]

.spin:
	pause

	cmp		dword [rsi + rw_lock.writer], 0
	jne		.spin

	jmp		.try

.ok:
	ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   rsi < rw_lock address

FUNCTION _rw_read_unlock
    lock dec dword [rsi + rw_lock.readers]
    ret
ENDFUNCTION
