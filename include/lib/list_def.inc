; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

%ifndef __LIST_DEF_INC__
%define __LIST_DEF_INC__

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

%endif ;__LIST_DEF_INC__
