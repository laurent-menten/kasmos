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
;	Try a bounded spin (with pause / backoff).
;	If acquisition doesn’t succeed quickly, block the thread (scheduler wait-queue) and get woken on release.
;
; Typical use cases:
;	Medium/long critical sections with variable contention;
;	kernel subsystems where wasting CPU is undesirable.
;
; Pros:
;	low latency when uncontended,
;	low CPU waste when contended;
;	reduces tail latencies.
;
; Cons:
;	More plumbing (scheduler hooks, wait-queues);
;	not IRQ-safe while sleeping;
;	tuning the spin budget matters.

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < spin_lock_t address

%define ARG_SPIN_LOCK r15

FUNCTION _hybrid_spin_lock_acquire
	push	rax
	push	rbx

	xor 	ebx, ebx
.try:
	mov		rax, 1
	xchg	rax, [ARG_SPIN_LOCK + spin_lock_t.val]
	test	rax, rax
	jz		.ok

.spin:
	pause

	inc		ebx
	cmp		ebx, HYBRID_MAX_SPIN
	jb		.try

	%note	"TODO: implement"
;	mov		rax, r15
;	mov		rbx, LOCK_TYPE_HYBRID_SPIN
;	call	Scheduler_BlockOnLock

	xor		ebx, ebx
	jmp		.try

.ok:
	pop		rbx
	pop		rax
	ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < spin_lock_t address

%define ARG_SPIN_LOCK r15

FUNCTION _hybrid_spin_lock_release
	push	rax
	push	rbx

	mov		qword [ARG_SPIN_LOCK + spin_lock_t.val], 0

	%note	"TODO: implement"
;	mov 	rax, r15
;	mov		rbx, LOCK_TYPE_HYBRID_SPIN
;	call	Scheduler_UnblockOneWaiter

	pop		rbx
	pop		rax
	ret
ENDFUNCTION
