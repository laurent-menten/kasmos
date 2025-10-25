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
;   rax > node removed or null

FUNCTION __list_remove_node_at_tail_unlocked
    push    rdx

    mov     rax, [rbx + linked_list.tail]       ; rax = tail
    test    rax, rax
    jz      .return

    sub     dword [rbx + linked_list.count], 1

    mov     rdx, [rax + linked_list_node.prev]       ; rdx = tail.prev
    mov     [rbx + linked_list.tail], rdx
    test    rdx, rdx
    jz      .was_single

    mov     qword [rdx + linked_list_node.next], 0
    jmp     .clear_links

.was_single:
    mov     qword [rbx + linked_list.head], 0

.clear_links:
	mov     qword [rax + linked_list_node.next], 0
    mov     qword [rax + linked_list_node.prev], 0
	pop		rdx
    ret

.return:
    ret
ENDFUNCTION

FUNCTION __list_remove_node_at_tail_locked
    jmp     __list_remove_node_at_tail_unlocked
ENDFUNCTION
