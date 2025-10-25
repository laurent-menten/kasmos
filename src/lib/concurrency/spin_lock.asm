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
;	Single byte/word flag (0 free, 1 taken).
;	Acquire with atomic xchg; if busy, spin with pause until it clears.
;	No queue/fairness.
;
; Typical use cases:
;	Ultra-short critical sections;
;	very low contention;
;	early boot;
;	IRQ-off sections;
;	per-CPU or cache-hot structures.
;
; Pros:
;	Tiny, fastest in the uncontended case;
;	trivial to implement;
;	great on hot paths that really are brief.
;
; Cons:
;	Burns CPU while spinning;
;	scales poorly under contention (cache ping-pong);
;	no fairness (possible starvation).
;

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < spin_lock_t address

%define ARG_SPIN_LOCK r15

FUNCTION _spin_lock_acquire
	push	rax

.try:
	mov		rax, 1
	xchg	rax, [ARG_SPIN_LOCK + spin_lock_t.val]			; atomic
	test	rax, rax
	jz		.acquired

.spin:
	pause

	cmp		qword [ARG_SPIN_LOCK + spin_lock_t.val], 0
	jne		.spin

	jmp		.try

.acquired:
    pop		rax
    ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < spin_lock_t address

%define ARG_SPIN_LOCK r15

FUNCTION _spin_lock_release
    mov     qword [ARG_SPIN_LOCK + spin_lock_t.val], 0
    ret
ENDFUNCTION
