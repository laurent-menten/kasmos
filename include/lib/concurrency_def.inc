; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

%ifndef __CONCURRENCY_DEF_INC__
%define __CONCURRENCY_DEF_INC__

STRUCT spin_lock_t
	.val			resq 1									; uint64_t
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

STRUCT ticket_lock_t
	.next			resd 1									; uint32_t
	.owner			resd 1									; uint32_t
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

STRUCT seq_lock_t
	.seq			resq 1									; uint64_t
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

STRUCT mcs_lock_node_t
	.next			resq 1									; struct mcs_lock_node*
	.locked			resq 1									; uint64_t
ENDSTRUCT

STRUCT mcs_lock_t
	.tail			resq 1									; struct mcs_lock_node*
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

STRUCT rw_lock
	.readers		resd 1									; uint32_t
	.writer			resd 1									; uint32_t
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

STRUCT mutex_t
	.state			resq 1									; uint64_t
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

STRUCT semaphore_t
	.count			resq 1									; uint64_t
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

LOCK_TYPE_SPIN				equ	0
LOCK_TYPE_HYBRID_SPIN		equ	1
LOCK_TYPE_TICKET			equ	2
LOCK_TYPE_SEQ				equ	3
LOCK_TYPE_MCS				equ	4
LOCK_TYPE_RW				equ	5
LOCK_TYPE_MUTEX				equ	6
LOCK_TYPE_SEMAPHORE			equ	7

%endif ;__CONCURRENCY_DEF_INC__
