; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

; =====================================================================================================================
; = 
; =====================================================================================================================

;   rbx < list
;   rsi < node

FUNCTION __list_add_node_at_head_unlocked
    push    rax

    mov     rax, [rbx + linked_list.head]                   ; rax = head

    mov     qword [rsi + linked_list_node.prev], 0          ; our prev = null
    mov     [rsi + linked_list_node.next], rax              ; our next = old head

    test    rax, rax                                        ; no head ?
    jz      .list_empty

    mov     [rax + linked_list_node.prev], rsi              ; old head's prev = node
    jmp     .set_list_head

.list_empty:
    mov     [rbx + linked_list.tail], rsi                   ; tail = node

.set_list_head:
    mov     [rbx + linked_list.head], rsi                   ; new head = node 

    add     dword [rbx + linked_list.count], 1

    pop     rax
    ret

FUNCTION __list_add_node_at_head_locked
    jmp     __list_add_node_at_head_unlocked
