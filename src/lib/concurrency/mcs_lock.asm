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
;	Global tail pointer (1 qword).
;	Each thread uses its own qnode {next, locked}.
;	Acquire: atomically splice your node at tail; if a predecessor exists, link and spin locally on your own locked.
;	Release: hand off to successor or clear tail.
;
; Typical use cases:
;	High contention;
;	many cores/NUMA;
;	longer critical sections;
;	global structures (run-queues, central allocators) that see bursts.
;
; Pros:
;	Scales excellently (no cache ping-pong on one line);
;	FIFO fairness;
;	each waiter spins on its own cache line.
;
; Cons:
;	Requires one node per thread (best in TLS);
;	higher overhead than TAS for tiny sections;
;	more code surface.
;

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < mcs_lock address
;   r14 < mcs__lock_node address

%define ARG_MCS_LOCK r15
%define ARG_MCS_LOCK_NODE r14

FUNCTION _mcs_lock_acquire
	push	rax
	push	r14

	mov		qword [ARG_MCS_LOCK_NODE + mcs_lock_node_t.next], 0
	mov		qword [ARG_MCS_LOCK_NODE + mcs_lock_node_t.locked], 1

	xchg	r14, [ARG_MCS_LOCK + mcs_lock_t.tail]

	test	r14, r14
	jz		.acquired_direct

	mov		r15, [r15 + mcs_lock_t.tail]

.mcs_lock_acquire_restart:
    mov		qword [r14 + mcs_lock_node_t.next], 0
    mov		qword [r14 + mcs_lock_node_t.locked], 1

    mov		rax, r14
    xchg	r14, [r15 + mcs_lock_t.tail]

    test	r14, r14
    jz		.acquired_direct

    mov		[r14 + mcs_lock_node_t.next], rax

.wait_unlock:
    pause

    cmp		qword [rax + mcs_lock_node_t.locked], 0
    jne		.wait_unlock

	pop		r14
	pop		rax
    ret

.acquired_direct:
    mov		qword [rax + mcs_lock_node_t.locked], 0

	pop		r14
	pop		rax
    ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < mcs_lock address
;   r14 < mcs__lock_node address

%define ARG_MCS_LOCK r15
%define ARG_MCS_LOCK_NODE r14

FUNCTION _mcs_lock_try_acquire
	mov		qword [ARG_MCS_LOCK_NODE + mcs_lock_node_t.next], 0
	mov		qword [ARG_MCS_LOCK_NODE + mcs_lock_node_t.locked], 1

	xor		rax, rax
	lock cmpxchg qword [ARG_MCS_LOCK + mcs_lock_t.tail], r14
	jnz		.fail

	mov		qword [ARG_MCS_LOCK_NODE + mcs_lock_node_t.locked], 0
	mov		rax, 1
	ret

.fail:
	xor		rax, rax
	ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < mcs_lock address
;   r14 < mcs__lock_node address

%define ARG_MCS_LOCK r15
%define ARG_MCS_LOCK_NODE r14

FUNCTION _mcs_lock_release
	push	rax

	mov		rax, [ARG_MCS_LOCK_NODE + mcs_lock_node_t.next]
	test	rax, rax
	jnz		.has_successor

	xor		rax,  rax
	lock cmpxchg qword [ARG_MCS_LOCK + mcs_lock_t.tail], rax
	jz		.done

.wait_link:
	mov		rax, [ARG_MCS_LOCK_NODE + mcs_lock_node_t.next]
	test	rax, rax
	jz		.wait_link

.has_successor:
	mov		dword [ARG_MCS_LOCK_NODE + mcs_lock_node_t.locked], 0

.done:
	pop		rax
	ret
ENDFUNCTION
