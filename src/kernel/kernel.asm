; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     X64
	bits    64

    %include "limine.inc"

	%include "cpu_control_block.inc"
	%include "thread_control_block.inc"

; =====================================================================================================================
; = Limine ============================================================================================================
; =====================================================================================================================

	section .limine_requests_start

	LIMINE_REQUESTS_START_MARKER

; ---------------------------------------------------------------------------------------------------------------------

	section .limine_requests

	LIMINE_BASE_REVISION 3

; ---------------------------------------------------------------------------------------------------------------------

	global _limine_executable_command_line_request
	global _limine_executable_command_line_request.response
_limine_executable_command_line_request:
	istruc limine_executable_cmdline_request
		LIMINE_REQUEST_HEADER					LIMINE_EXECUTABLE_CMDLINE_REQUEST_2, LIMINE_EXECUTABLE_CMDLINE_REQUEST_3
.response:
		at limine_mp_request.response,          dq 0
	iend

    global _limine_mp_request
    global _limine_mp_request.response
_limine_mp_request:
	istruc limine_mp_request
		LIMINE_REQUEST_HEADER                   LIMINE_MP_REQUEST_2, LIMINE_MP_REQUEST_3
.response:
		at limine_mp_request.response,          dq 0
		at limine_mp_request.flags,             dq 0
	iend

    global _limine_framebuffer_request
    global _limine_framebuffer_request.response
_limine_framebuffer_request:
	istruc limine_framebuffer_request
		LIMINE_REQUEST_HEADER                   LIMINE_FRAMEBUFFER_REQUEST_2, LIMINE_FRAMEBUFFER_REQUEST_3
.response:
		at limine_framebuffer_request.response, dq 0
	iend

; ---------------------------------------------------------------------------------------------------------------------

	section .limine_requests_end

	LIMINE_REQUESTS_END_MARKER

; =====================================================================================================================
; = BSP control blocks ================================================================================================
; =====================================================================================================================

DATA _bsp_cpu_control_block
	istruc cpu_control_block
	iend

DATA _bsp_idle_thread_control_block
	istruc bsp_thread_control_block
        at .foobar,     	dq  PANIC_CODE_NO_ERROR
	iend

; ---------------------------------------------------------------------------------------------------------------------

%macro PARAMETER 1
	istruc kvpair
		at .key,			dq	%1
		at .value,			dq 	0
	iend
%endmacro

DATA _kernel_parameters
	PARAMETER	_kernel_parameter_debug
	PARAMETER	_kernel_parameter_loglevel
	dq			0

RODATA _kernel_parameter_debug
	db "debug",0

RODATA _kernel_parameter_loglevel
	db "loglevel",0