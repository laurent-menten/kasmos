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
;	0/1 state in the lock word;
;	if busy, the caller blocks on a wait-queue (scheduler) and is woken on unlock.
;	No spinning in the contended path.
;
; Typical use cases:
;	Long critical sections;
;	code paths that may sleep or must not burn CPU;
;	higher-level kernel services and syscalls.
;
; Pros:
;	No active spinning under contention;
;	good for long or unpredictable sections;
;	integrates with priorities and scheduling.
;
; Cons:
;	Not usable in IRQ context;
;	scheduler/wait-queue overhead;
;	potential priority inversion (mitigate with priority inheritance if needed).
;

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < mutex_t address

FUNCTION _mutex_init
	%define ARG_MUTEX r15

	mov		qword [ARG_MUTEX + mutex_t.state], 0
	ret

ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < mutex_t address

FUNCTION _mutex_lock
	%define ARG_MUTEX r15

	push	rax

.try:
	mov		rax, 1
	xchg	rax, [ARG_MUTEX + mutex_t.state]
	test	rax, rax
	jz		.ok

	%note	"TODO: implement"
;	mov		rax, ARG_MUTEX
;	call	Scheduler_BlockOnLock

	jmp		.try

.ok:
	pop		rax
	ret

ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < mutex_t address

FUNCTION _mutex_unlock
	%define ARG_MUTEX r15

	mov		qword [ARG_MUTEX + mutex_t.state], 0

	%note	"TODO: implement"
;	mov		rax, ARG_MUTEX
;	call	Scheduler_UnblockOneWaiter

	ret

ENDFUNCTION
