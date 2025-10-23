; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

    %include "lib/list.inc"

; =====================================================================================================================
; = 
; =====================================================================================================================

;   rbx < list
;   rsi < new node
;	rdi < existing node

FUNCTION __list_insert_before_node_unlocked
	push	rax

    mov     rax, [rdi + linked_list_node.prev]				; rax = existing next

    mov     [rsi + linked_list_node.prev], rax				; our next = existing next
    mov     [rsi + linked_list_node.next], rdi				; our prev = existing

    test    rax, rax										; no existing next ?
    jz      .is_tail

    mov     [rax + linked_list_node.next], rsi				; we are prev of existing nex
    jmp     .link_pos

.is_tail:
    mov     [rbx + linked_list.head], rsi					; tail = us				

.link_pos:
    mov     [rdi + linked_list_node.prev], rsi				; existing next = us

    add     dword [rbx + linked_list.count], 1

	pop		rax
    ret

FUNCTION __list_insert_before_node_locked
    jmp     __list_insert_before_node_unlocked
