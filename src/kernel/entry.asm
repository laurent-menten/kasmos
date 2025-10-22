; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     X64
	bits    64

	%include "kernel_panic.inc"

	%include "limine.inc"

; =====================================================================================================================
; =
; =====================================================================================================================

	extern vdebug_write_string
	extern vdebug_write_word

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
	BOCHS_MAGIC_BREAK

	extern _list_test
	call _list_test

	; -----------------------------------------------------------------------------------------------------------------

	mov     rsi, txt_hello
	call    vdebug_write_string

	; -----------------------------------------------------------------------------------------------------------------
	; r15 will always hold the kasmos_master_list address when in kernel code.
	; -----------------------------------------------------------------------------------------------------------------

	mov		r15, _kasmos_master_list

	; -----------------------------------------------------------------------------------------------------------------
	; Setup the kernel allocator data
	; -----------------------------------------------------------------------------------------------------------------

	extern	__kernel_data_buffer_start
	extern	__kernel_data_buffer_end

	lea		rdi, [r15 + kasmos_master_list.kmem]

	mov 	rax, __kernel_data_buffer_start

	mov		[rdi + kasmos_kmem.kmem_base], rax
	mov		[rdi + kasmos_kmem.kmem_freebase], rax

	mov		rbx, __kernel_data_buffer_end
	sub		rbx, rax

	mov		[rdi + kasmos_kmem.kmem_size], rbx
	mov		[rdi + kasmos_kmem.kmem_avail], rbx

	; -----------------------------------------------------------------------------------------------------------------
	; 
	; -----------------------------------------------------------------------------------------------------------------

	extern	_limine_mp_request

	mov		rsi, _limine_mp_request
	mov		rsi, [rsi + limine_mp_request.response]
	and		rsi, rsi
	jnz		.mp_response_available

	KERNEL_PANIC PANIC_CODE_NO_MP_INFOS

.mp_response_available:

	mov		rcx, [rsi + limine_mp_response.cpu_count]

	mov		rax, kasmos_cpu_data_block_size
	mul		rax, rcx


















	PUSH_ARGS	rax, rbx
	call    .z
	POP_ARGS


.z  pop     rax
	mov     cl, 16
	call    vdebug_write_word
	mov     rsi, cr_lf
	call    vdebug_write_string

	mov     cl, 12
	call    vdebug_write_word
	mov     rsi, cr_lf
	call    vdebug_write_string

	; -----------------------------------------------------------------------------------------------------------------
	; 
	; -----------------------------------------------------------------------------------------------------------------

	extern kinit_run_all

	call    kinit_run_all

	; -----------------------------------------------------------------------------------------------------------------
	; 
	; -----------------------------------------------------------------------------------------------------------------

	; ....

	; -----------------------------------------------------------------------------------------------------------------
	; 
	; -----------------------------------------------------------------------------------------------------------------

	extern kfini_run_all

	call    kfini_run_all

.hang:
	BOCHS_MAGIC_BREAK

.hang_loop:
	hlt
	jmp .hang_loop

	section .data

; =====================================================================================================================
; = 
; =====================================================================================================================

RODATA txt_hello
	db  'kasmos booting...'

RODATA cr_lf
	db  10, 13, 0

