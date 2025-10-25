; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     X64
	bits    64

	%include "x86_64.inc"
	%include "cpu_control_block.inc"
	%include "thread_control_block.inc"
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

;	extern _list_test
;	call _list_test

	section .text    

FUNCTION _kernel_entrypoint

	BOCHS_MAGIC_BREAK

	extern _limine_executable_command_line_request.response
	extern _kernel_parameters
	extern _parse_command_line

	mov		rsi, txt_cmdline
	call	vdebug_write_string

	mov		rsi, _limine_executable_command_line_request.response
	mov		rsi, [rsi]
	test	rsi, rsi
	jz		.skip_command_line

	mov		r8, [rsi + limine_executable_cmdline_response.cmdline]
	test	r8, r8
	jz		.skip_command_line

	call	vdebug_write_string

	mov		rsi, txt_crlf
	call	vdebug_write_string

	mov		rsi, r8
	mov		rdi, _kernel_parameters
	call	_parse_command_line

	mov		rdi, _kernel_parameters
.params_loop:
	mov		rsi, [rdi + kvpair.key]
	test	rsi, rsi
	jz		.skip_command_line

	call	vdebug_write_string

	mov		rsi, txt_equal
	call	vdebug_write_string

	mov		rsi, [rdi + kvpair.value]
	test	rsi, rsi
	jz		.no_param_value

	call	vdebug_write_string

.no_param_value:
	mov		rsi, txt_crlf
	call	vdebug_write_string

	add		rdi, kvpair.size
	jmp		.params_loop

.skip_command_line:

	extern _ksym_sort
	extern _ksym_dump

	call	_ksym_sort
	call	_ksym_dump

	; -----------------------------------------------------------------------------------------------------------------
	; Setup GS: base addresses for the BSP (BootStrap Processor) control block
	; -----------------------------------------------------------------------------------------------------------------

	extern _bsp_cpu_control_block

	mov		rsi, _bsp_cpu_control_block
	mov		eax, esi
	shr		rsi, 32
	mov		edx, esi

	mov		ecx, IA32_GS_BASE
	wrmsr

	mov		ecx, IA32_KERNEL_GS_BASE
	wrmsr

	mov		eax, [gs: cpu_control_block.user]

	; -----------------------------------------------------------------------------------------------------------------
	; Setup FS: base address for the idle thread control block of the BSP
	; -----------------------------------------------------------------------------------------------------------------

	extern _bsp_idle_thread_control_block

	mov		rsi, _bsp_idle_thread_control_block
	mov		eax, esi
	shr		rsi, 32
	mov		edx, esi

	mov		ecx, IA32_FS_BASE
	wrmsr

	; -----------------------------------------------------------------------------------------------------------------
	; -----------------------------------------------------------------------------------------------------------------

	mov     rsi, txt_hello
	call    vdebug_write_string

	; -----------------------------------------------------------------------------------------------------------------
	; r15 will always hold the kasmos_master_list address when in kernel code.
	; -----------------------------------------------------------------------------------------------------------------

;	mov		r15, _kasmos_master_list

	; -----------------------------------------------------------------------------------------------------------------
	; Setup the kernel allocator data
	; -----------------------------------------------------------------------------------------------------------------

;	extern __kernel_data_buffer_start
;	extern __kernel_data_buffer_end

;	lea		rdi, [r15 + kasmos_master_list.kmem]

;	mov 	rax, __kernel_data_buffer_start

;	mov		[rdi + kasmos_kmem.kmem_base], rax
;	mov		[rdi + kasmos_kmem.kmem_freebase], rax

;	mov		rbx, __kernel_data_buffer_end
;	sub		rbx, rax

;	mov		[rdi + kasmos_kmem.kmem_size], rbx
;	mov		[rdi + kasmos_kmem.kmem_avail], rbx

	; -----------------------------------------------------------------------------------------------------------------
	; 
	; -----------------------------------------------------------------------------------------------------------------

	extern _limine_mp_request

	mov		rsi, _limine_mp_request
	mov		rsi, [rsi + limine_mp_request.response]
	and		rsi, rsi
	jnz		.mp_response_available

	KERNEL_PANIC PANIC_CODE_NO_MP_INFOS

.mp_response_available:

	mov		rcx, [rsi + limine_mp_response.cpu_count]

	mov		rax, kasmos_cpu_data_block_size
	mul		rax, rcx


	; -----------------------------------------------------------------------------------------------------------------
	; 
	; -----------------------------------------------------------------------------------------------------------------

	extern kinit_run_all

	call    kinit_run_all

	; -----------------------------------------------------------------------------------------------------------------
	; 
	; -----------------------------------------------------------------------------------------------------------------

	; TODO: call main

	; -----------------------------------------------------------------------------------------------------------------
	; 
	; -----------------------------------------------------------------------------------------------------------------

	extern kfini_run_all

	call    kfini_run_all

.hang:
	mov     rsi, txt_kernel_stopped
	call    vdebug_write_string

.hang_loop:
	BOCHS_MAGIC_BREAK

	hlt
	jmp .hang_loop

ENDFUNCTION

; =====================================================================================================================
; = 
; =====================================================================================================================

RODATA txt_hello
	db  'kasmos booting...', 10, 13, 0

RODATA txt_kernel_stopped
	db	'Kernel stopped.', 10, 13, 0

RODATA txt_cmdline
	db	'Command line: ', 0

RODATA txt_symbols
	db	10, 13, 'Sorted symbols: ', 0

RODATA txt_equal
	db	' = ', 0

RODATA txt_crlf
	db  10, 13, 0

