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
;   Two 32-bit counters in one qword:
;       next (fetch-and-increment on acquire)
;       owner (increment on release).
;   Waits until owner == my_ticket.
;
; Typical use cases:
;   Need fairness with small/medium contention;
;   moderate-length critical sections;
;   shared data touched by several CPUs.
;
; Pros:
;   FIFO fairness;
;   simple and predictable;
;   still compact.
;
; Cons:
;   Active spinning;
;   shared owner line bounces under contention;
;   slower than spin lock when contention is truly negligible.
;

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < ticket_lock_t address

%define ARG_TICKET_LOCK r15

FUNCTION _ticket_lock_acquire
	push	rax

    mov     eax, 1
	lock xadd dword [ARG_TICKET_LOCK + ticket_lock_t.next], eax

.wait_owner:
    cmp     dword [ARG_TICKET_LOCK + ticket_lock_t.owner], eax
    je      .ok

    pause

    jmp     .wait_owner

.ok:
    pop     rax
    ret
ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

;   r15 < ticket_lock_t address

%define ARG_TICKET_LOCK r15

FUNCTION _ticket_lock_release
	lock inc dword [ARG_TICKET_LOCK + ticket_lock_t.owner]
	ret
ENDFUNCTION
