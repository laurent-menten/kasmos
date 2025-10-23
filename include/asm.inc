; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

; NOTE: this file is automaticaly included (in second position!).
; See NASM_FLAGS definition in Makefile.rules

; =====================================================================================================================
; = 
; =====================================================================================================================

%macro STRUCT 1
	%push struct_context
	%define __STRUCT_NAME %1
	struc %1
%endmacro

%macro LINKED_STRUCT 1
	%push struct_context
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
	%pop
%endmacro
