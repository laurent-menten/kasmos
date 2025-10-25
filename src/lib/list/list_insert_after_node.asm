; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

    %include "lib/list_def.inc"

; =====================================================================================================================
; = 
; =====================================================================================================================

;   rbx < list
;   rsi < new node
;	rdi < existing node

FUNCTION __list_insert_after_node_unlocked
	push	rax

    mov     rax, [rdi + linked_list_node.next]				; rax = existing prev

    mov     [rsi + linked_list_node.next], rax				; our prev = existing prev
    mov     [rsi + linked_list_node.prev], rdi				; our next = existing

    test    rax, rax										; no existing prev ?
    jz      .is_head

    mov     [rax + linked_list_node.prev], rsi				; we are next of existing prev
    jmp     .link_pos

.is_head:
    mov     [rbx + linked_list.tail], rsi					; head = us

.link_pos:
    mov     [rdi + linked_list_node.next], rsi				; existing prev = us

    add     dword [rbx + linked_list.count], 1

	pop		rax
    ret
ENDFUNCTION

FUNCTION __list_insert_after_node_locked
    jmp     __list_insert_after_node_unlocked
ENDFUNCTION
