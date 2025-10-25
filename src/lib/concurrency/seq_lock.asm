; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

	%include "lib/concurrency_def.inc"

; =====================================================================================================================
; = 
; =====================================================================================================================
;
; Technique:
;	64-bit sequence counter
;		even when idle,
;		odd during write.
;	Readers read seq, read data, reread seq; if changed or odd, retry.
;	Writer increments before and after update.
;
; Typical use cases:
;	Read-mostly snapshots (timekeeping, stats, cursors);
;	writers are short and cannot sleep;
;	readers can tolerate retry.
;
; Pros:
;	Readers are lock-free and very fast;
;	great throughput when writes are rare;
;	compact.
;
; Cons:
;	Readers may have to retry (no side effects allowed while reading);
;	writers must be brief and non-sleeping;
;	no fairness guarantees.
;

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < seq_lock_t address

%define ARG_SEQ_LOCK r15

FUNCTION _seq_lock_write_lock
	lock inc qword [ARG_SEQ_LOCK + seq_lock_t.seq]   ; even -> odd
	ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < seq_lock_t address

%define ARG_SEQ_LOCK r15

FUNCTION _seq_lock_write_unlock
	lock inc qword [ARG_SEQ_LOCK + seq_lock_t.seq]   ; odd -> even
	ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < seq_lock_t address
;   rax > seq (even)

%define ARG_SEQ_LOCK r15

FUNCTION _seq_lock_read_begin
.retry:
	mov		rax, qword [ARG_SEQ_LOCK + seq_lock_t.seq]
	test	rax, 1
	jz		.done

	pause

	jmp     .retry

.done:
	ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < seq_lock_t address
;	rax < seq
;   rax > (bool) need retry

%define ARG_SEQ_LOCK r15

FUNCTION _seq_lock_read_retry
	push	rbx
	mov		rbx, rax

	mov		rax, qword [ARG_SEQ_LOCK + seq_lock_t.seq]
	cmp     rax, rbx
	jne     .retry_needed

	test    rax, 1
	jnz     .retry_needed

.no_retry:
	xor     rax, rax

	pop		rbx
	ret

.retry_needed:
	mov     rax, 1

	pop		rbx
	ret
ENDFUNCTION
