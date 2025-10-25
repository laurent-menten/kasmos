; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

; NOTE: this file is automaticaly included (in second position!).
; See NASM_FLAGS definition in Makefile.rules


; =====================================================================================================================
; = Helpers for emiting to the correct section ========================================================================
; =====================================================================================================================

%macro FUNCTION 1
	%ifctx FUNCTION_CTX
		%error Nesting functions is not supported, add ENDFUNCTION to FUNCTION_NAME
	%endif

	%push FUNCTION_CTX
	%define FUNCTION_NAME %1

	[SECTION .text]
	global %1: function
%1:
%endmacro

%macro ENDFUNCTION 0
	.size:

	%if ENABLE_KERNEL_SYMBOLS_LIST != 0

		[SECTION .kernel_symbols_data]
		dq			FUNCTION_NAME
		dq			FUNCTION_NAME %+ _meta

		[SECTION .kernel_symbols_meta]
		FUNCTION_NAME %+ _meta:
			dq		FUNCTION_NAME %+ _name
			dq		FUNCTION_NAME %+ .size - FUNCTION_NAME

		[SECTION .kernel_symbols_names]
		FUNCTION_NAME %+ _name:
			db		%str(FUNCTION_NAME), 0

	%endif

	%pop FUNCTION_CTX
%endmacro

; ---------------------------------------------------------------------------------------------------------------------

%macro DATA 1
	[SECTION .data]
	global %1
%1:
%endmacro

%macro RODATA 1
	[SECTION .rodata]
	global %1
%1:
%endmacro

; =====================================================================================================================
; = Helpers for structures ============================================================================================
; =====================================================================================================================

%macro STRUCT 1
	%push STRUCT_CTX
	%define __STRUCT_NAME %1
	struc %1
%endmacro

%macro LINKED_STRUCT 1
	%push STRUCT_CTX
	%define __STRUCT_NAME %1
	struc %1
		.next				resq	1
		.prev				resq	1
%endmacro

; ---------------------------------------------------------------------------------------------------------------------

%macro ENDSTRUCT 0
	.size:
	endstruc
;	%xdefine __STRUCT_NAME %+ _size __STRUCT_NAME %+ _size
	%undef __STRUCT_NAME
	%pop STRUCT_CTX
%endmacro

; ---------------------------------------------------------------------------------------------------------------------

%define SIZEOF( type ) (type %+ .size)
%define SIZEOF( type, count ) (count * type %+ .size)
