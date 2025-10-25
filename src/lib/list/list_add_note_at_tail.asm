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
;   rsi < node

FUNCTION __list_add_node_at_tail_unlocked
    push    rax

    mov     rax, [rbx + linked_list.tail]                   ; rax = tail

    mov     qword [rsi + linked_list_node.next], 0          ; our next = null
    mov     [rsi + linked_list_node.prev], rax              ; our prev = old tail

    test    rax, rax                                        ; no tail ?
    jz      .list_empty

    mov     [rax + linked_list_node.next], rsi              ; old tail's next = node
    jmp     .set_list_tail

.list_empty:
    mov     [rbx + linked_list.head], rsi                   ; head = node

.set_list_tail:
    mov     [rbx + linked_list.tail], rsi                   ; new tail = node 

    add     dword [rbx + linked_list.count], 1

    pop     rax
    ret
ENDFUNCTION

FUNCTION __list_add_node_at_tail_locked
    jmp     __list_add_node_at_tail_unlocked
ENDFUNCTION
