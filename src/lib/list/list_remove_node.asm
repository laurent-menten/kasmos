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
;   rsi < node
;   rax > node removed or null

FUNCTION __list_remove_node_unlocked
    push    rdx

    test    rsi, rsi
    jz      .return

    sub     dword [rbx + linked_list.count], 1

    mov     rax, [rsi + linked_list_node.next]
    mov     rdx, [rsi + linked_list_node.prev]

.check_prev:
    test    rdx, rdx
    jz      .no_prev

    mov     [rdx + linked_list_node.next], rax
    jmp     .check_next

.no_prev:
    mov     [rbx + linked_list.head], rax

.check_next:
    test    rax, rax
    jz      .no_next

    mov     [rax + linked_list_node.prev], rdx
    jmp     .patch_node

.no_next:
    mov     [rbx + linked_list.tail], rdx

.patch_node:
    mov     qword [rsi + linked_list_node.next], 0
    mov     qword [rsi + linked_list_node.prev], 0

    mov     rax, rsi
    pop     rdx
    ret

.return:
    xor     eax, eax
    pop     rdx
    ret

FUNCTION __list_remove_node_locked
    jmp     __list_remove_node_unlocked