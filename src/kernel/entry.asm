; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

    cpu     X64
    bits    64

    %include "limine.inc"

; =====================================================================================================================
; =
; =====================================================================================================================

    extern vdebug_write_string

    extern kinit_run_all
    extern kfini_run_all

; =====================================================================================================================
; = Limine ============================================================================================================
; =====================================================================================================================

    section .limine_requests_start

    LIMINE_REQUESTS_START_MARKER

    section .limine_requests

    LIMINE_BASE_REVISION 3


_limine_mp_request:
    istruc limine_mp_request
        LIMINE_REQUEST_HEADER                   LIMINE_MP_REQUEST_2, LIMINE_MP_REQUEST_3
.response:
        at limine_mp_request.response,          dq 0
        at limine_mp_request.flags,             dq 0
    iend

_limine_framebuffer_request:
    istruc limine_framebuffer_request
        LIMINE_REQUEST_HEADER                   LIMINE_FRAMEBUFFER_REQUEST_2, LIMINE_FRAMEBUFFER_REQUEST_3
.response:
        at limine_framebuffer_request.response, dq 0
    iend

    section .limine_requests_start

    LIMINE_REQUESTS_END_MARKER

; =====================================================================================================================
; = Entrypoint ========================================================================================================
; =====================================================================================================================
;
; Machine state at entry (as set by limine)
;
; gdt (in bootloader-reclaimable memory):
;   0 null
;   1 16 bits, 0, 0xFFFF r x
;   2 16 bits, 0, 0xFFFF w
;   3 32 bits, 0, 0xFFFFFF r x
;   4 32 bits, 0, 0xFFFFFF w
;   5 64 bits, 0, 0xFFFF r x
;   6 64 bits, 0, 0xFFFF w
;
; idt : undefined.
;
; (cr0) PG, PE, WP enabled, (cr4) PAE enabled, (efer) LME and NX enebled.
; (cr4) LA57 enabled if available and requested.
;
; rip : from elf or EntryPoint request.
; rsp : stack pointer from bootloader-reclaimable memory, at least 64K or from StackSize request.
; other registers : 0.
; rflags: IF, VM, DF cleared, other undefined.
;
; A20 opened.
; Legacy PIC and IO APIC IRQs (only those with delivery mode fixed (0b000) or lowest priority (0b001)) all masked.
; Boot services (EFI/UEFI) exited.
;

    section .text    

    global _kernel_entrypoint
_kernel_entrypoint:
    mov rsi, hello
    call vdebug_write_string

    call    kinit_run_all

    nop

    call    kfini_run_all

.hang:
    hlt
    jmp .hang

    section .data

; =====================================================================================================================
; = 
; =====================================================================================================================

hello:
    db 'kasmos booting...', 10, 0

