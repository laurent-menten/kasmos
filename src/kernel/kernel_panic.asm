; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

	%include "thread_control_block.inc"

	extern vdebug_write_string
	extern vdebug_write_word

; =====================================================================================================================
; = 
; =====================================================================================================================

FUNCTION _kernel_panic

	BOCHS_MAGIC_BREAK

	mov     rsi, txt_kernel_panic_1
	call    vdebug_write_string

	extern _kasmos_master_list

	mov		rax, qword [fs: thread_control_block.panic_code]
	mov		rcx, 16
	call	vdebug_write_word

	mov     rsi, txt_kernel_panic_2
	call    vdebug_write_string

.loop:
	hlt
	jmp .loop

RODATA txt_kernel_panic_1
	db	'Kernel Panic : code = ', 0

RODATA txt_kernel_panic_2
	db	' !!!', 10, 13, 0
