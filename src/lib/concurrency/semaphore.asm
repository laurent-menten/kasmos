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
;	64-bit counter in the lock word.
;	down() atomically decrements;
;	if the count was 0, block.
;	up() increments and wakes one waiter.
;
; Typical use cases:
;	Access to a pool of N identical resources (buffers, slots);
;	producer/consumer coordination;
;	throttling.
;
; Pros:
;	Natural fit for resource counting;
;	can wake exactly one waiter;
;	avoids busy-wait.
;
; Cons:
;	Heavier than spin locks;
;	needs scheduler integration;
;	misuse as a general mutex leads to confusion and bugs.
;

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < semaphore address
;	rax < initial value

%define ARG_SEMAPHORE r15
%define ARG_INITIAL_COUNT rax

FUNCTION _semaphore_init
	mov		qword [ARG_SEMAPHORE + semaphore_t.count], ARG_INITIAL_COUNT
	ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < semaphore address

%define ARG_SEMAPHORE r15

FUNCTION _semaphore_down
	push	rax

.try:
	mov		rax, - 1
	lock xadd qword [ARG_SEMAPHORE + semaphore_t.count], rax
	cmp		rax, 1
	jge		.return

	lock inc qword [ARG_SEMAPHORE + semaphore_t.count]

	%note	"TODO: implement"
;	mov		rax, ARG_SEMAPHORE
;	call	Scheduler_BlockOnLock

	test	rax, rax
	jnz		.return

.block:

	jmp		.try

.return:
	pop  rax
	ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < semaphore address

%define ARG_SEMAPHORE r15

FUNCTION _semaphore_up
	lock inc qword [ARG_SEMAPHORE + semaphore_t.count]

	%note	"TODO: implement"
;	mov		rax, rsi
;	call	Scheduler_UnblockOneWaiter

	ret
ENDFUNCTION
