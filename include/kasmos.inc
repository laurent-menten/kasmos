; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

; NOTE: this file is automaticaly included (in second position!).
; See NASM_FLAGS definition in Makefile.rules


%ifndef __KASMOS_INC__
%define __KASMOS_INC__

; =====================================================================================================================
; = Debug helpers =====================================================================================================
; =====================================================================================================================

; make bochs enter debugger
; requires [magic_break: enabled=1] in bochsrc.txt

%macro BOCHS_MAGIC_BREAK 0
	xchg    bx, bx
%endmacro

; i/o port use to send text to the console
; requires [port_e9_hack: enabled=1] in bochsrc.txt

%define BOCHS_HACK_PORT 0xE9

; =====================================================================================================================
; = Helpers for emiting to the correct section ========================================================================
; =====================================================================================================================

%macro FUNCTION 1
	[SECTION .text]
	global %1
%1:
%endmacro

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
; = Init/Fini system ==================================================================================================
; =====================================================================================================================

%macro KERNEL_INIT 1-2 100
	[SECTION .kinit.%2  PROGBITS ALLOC NOEXEC NOWRITE ALIGN=8]
	DQ %1
	__SECT__
%endmacro

%macro KERNEL_FINI 1-2 100
	[SECTION .kfini.%2  PROGBITS ALLOC NOEXEC NOWRITE ALIGN=8]
	DQ %1
	__SECT__
%endmacro

%endif ;__KASMOS_INC__
