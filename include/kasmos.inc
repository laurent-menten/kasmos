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

; =====================================================================================================================
; = variadic
; =====================================================================================================================

%macro PUSH_ARGS 1-*.

	%push PUSH_ARGS_CTX
	%xdefine %$PushSize 0

	%rep %0
		; Heuristique simple :
		; - si c'est un registre/mémoire → push direct
		; - si c'est un immédiat → on passe par sub/mov (imm64 OK)
	
		%ifidni %1, byte  || %ifidni %1, word  || %ifidni %1, dword || %ifidni %1, qword
			; Adresse mémoire explicitement typée
			push %1
		%elifid %1              ; identificateur (reg, label, etc.)
			push %1
		%else
			; Probablement un immédiat/expr → version sans clobber
			sub     rsp, 8
			mov     qword [rsp], %1
		%endif
	
		%xdefine %$PushSize %$PushSize + 8
		%rotate 1
	%endrep

%endmacro

%macro POP_ARGS 0

	add     rsp, %$PushSize
	%pop

%endmacro

; =====================================================================================================================
; = 
; =====================================================================================================================

%macro STRUCT 1
	%push struc_CTX
	%define __STRUCT_NAME %1
	struc %1
%endmacro

%macro LINKED_STRUCT 1
	%push struc_CTX
	%define __STRUCT_NAME %1
	struc %1
		.next				resq	1
		.prev				resq	1
%endmacro

; ---------------------------------------------------------------------------------------------------------------------

%macro ENDSTRUCT 0
	.size:
	endstruc
	%xdefine __STRUCT_NAME %+ _size __STRUCT_NAME %+ size
	%undef __STRUCT_NAME
	%pop
%endmacro

; =====================================================================================================================
; = 
; =====================================================================================================================

STRUCT linked_list
	.head					resq	1						; 
	.tail					resq	1						; 
	.count					resq	1						; 
	.flags					resq	1						; 
	.name					resq	1						; 
	.spinlock				resq	1						; spinlock ou pointer
	.owner_cpu				resw	1						; owning cpu
	.lock_owner_cpu			resw	1						; lock owner cpu
	.pad1					resw	1						; 
	.pad2					resw	2						; 
	.vtable					resq	1						; 
ENDSTRUCT

LL_FROZEN			equ		(1 << 0)
LL_POLICY_FIFO		equ		(1 << 1)
LL_POLICY_LIFO		equ		(0 << 1)
LL_LOCKED_ACCESS	equ		(1 << 2)
LL_UNLOCKED_ACCESS	equ		(0 << 2)
LL_CPU_PRIVATE		equ		(1 << 3)

LINKED_STRUCT linked_list_node
ENDSTRUCT

; =====================================================================================================================
; = 
; =====================================================================================================================

%define PANIC_CODE_NO_ERROR			0x0000_0000_0000_0000
%define PANIC_CODE_NO_MP_INFOS		0x8000_0000_0000_0001

; =====================================================================================================================
; = 
; =====================================================================================================================

STRUCT kasmos_kmem
	.kmem_base				resq	1
	.kmem_size				resq	1
	.kmem_freebase			resq	1
	.kmem_avail				resq	1
ENDSTRUCT

LINKED_STRUCT kasmos_cpu_data_block
	.a						resq	1
	.b						resq	1
	.c						resq	1
	.d						resq	1
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

STRUCT kasmos_master_list
	.panic_code				resq	1
	.kmem					resb	kasmos_kmem_size
	.cpu_list				resq	1
ENDSTRUCT

%endif ;__KASMOS_INC__
