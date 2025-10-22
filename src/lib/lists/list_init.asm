; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

; =====================================================================================================================
; = 
; =====================================================================================================================

struc list_vtable
    .is_empty               resq    1
    .add_node_at_head       resq    1
    .add_node_at_tail       resq    1
    .insert_before_node     resq    1
    .insert_after_node      resq    1
    .remove_node            resq    1
    .remove_node_at_head    resq    1
    .remove_node_at_tail    resq    1
endstruc

; ---------------------------------------------------------------------------------------------------------------------

    extern __list_is_empty_unlocked
    extern __list_add_node_at_head_unlocked
    extern __list_add_node_at_tail_unlocked
    extern __list_insert_before_node_unlocked
    extern __list_insert_after_node_unlocked
    extern __list_remove_node_unlocked
    extern __list_remove_node_at_head_unlocked
    extern __list_remove_node_at_tail_unlocked

RODATA _list_vtable_unlocked
    istruc list_vtable
        at .is_empty, dq __list_is_empty_unlocked
        at .add_node_at_head, dq __list_add_node_at_head_unlocked
        at .add_node_at_tail, dq __list_add_node_at_tail_unlocked
        at .insert_before_node, dq __list_insert_before_node_unlocked
        at .insert_after_node, dq __list_insert_after_node_unlocked
        at .remove_node, dq __list_remove_node_unlocked
        at .remove_node_at_head, dq __list_remove_node_at_head_unlocked
        at .remove_node_at_tail, dq __list_remove_node_at_tail_unlocked
    iend

    extern __list_is_empty_locked
    extern __list_add_node_at_head_locked
    extern __list_add_node_at_tail_locked
    extern __list_insert_before_node_locked
    extern __list_insert_after_node_locked
    extern __list_remove_node_locked
    extern __list_remove_node_at_head_locked
    extern __list_remove_node_at_tail_locked

RODATA _list_vtable_locked
    istruc list_vtable
        at .is_empty, dq __list_is_empty_locked
        at .add_node_at_head, dq __list_add_node_at_head_locked
        at .add_node_at_tail, dq __list_add_node_at_tail_locked
        at .insert_before_node, dq __list_insert_before_node_locked
        at .insert_after_node, dq __list_insert_after_node_locked
        at .remove_node, dq __list_remove_node_locked
        at .remove_node_at_head, dq __list_remove_node_at_head_locked
        at .remove_node_at_tail, dq __list_remove_node_at_tail_locked
    iend

; =====================================================================================================================
; = 
; =====================================================================================================================

;STRUCT linked_list
;	.head					resq	1						; 
;	.tail					resq	1						; 
;	.count					resq	1						; 
;	.flags					resq	1						; 
;	.spinlock				resq	1						; spinlock ou pointer
;	.owner_cpu				resw	1						; owning cpu
;	.lock_owner_cpu			resw	1						; lock owner cpu
;	.pad1					resw	1						; 
;	.pad2					resw	2						; 
;	.name					resq	1						; 
;	.vtable					resq	1						; 
;ENDSTRUCT

;   rbx < list
;   rax < flags

FUNCTION _list_init
    mov     qword [rbx + linked_list.head], 0
    mov     qword [rbx + linked_list.tail], 0
    mov     qword [rbx + linked_list.count], 0

    mov     qword [rbx + linked_list.flags], rax

    mov     qword [rbx + linked_list.spinlock], 0
    mov     word [rbx + linked_list.owner_cpu], 0
    mov     word [rbx + linked_list.lock_owner_cpu], 0

    mov     word [rbx + linked_list.pad1], 0
    mov     word [rbx + linked_list.pad2], 0

    mov     qword [rbx + linked_list.name], 0

    test    rax, LL_LOCKED_ACCESS
    jz      .locked_acces

    mov     qword [rbx + linked_list.vtable], _list_vtable_unlocked
    jmp     .return

.locked_acces:
    mov     qword [rbx + linked_list.vtable], _list_vtable_locked

.return:
    ret

; =====================================================================================================================
; = 
; =====================================================================================================================

FUNCTION _list_is_empty
    push    r8
    mov     r8, [rbx + linked_list.vtable]
    call    [r8 + list_vtable.is_empty]
    pop     r8
    ret

FUNCTION _list_add_node_at_head
    push    r8
    mov     r8, [rbx + linked_list.vtable]
    call    [r8 + list_vtable.add_node_at_head]
    pop     r8
    ret

FUNCTION _list_add_node_at_tail
    push    r8
    mov     r8, [rbx + linked_list.vtable]
    call    [r8 + list_vtable.add_node_at_tail]
    pop     r8
    ret

FUNCTION _list_insert_before_node
    push    r8
    mov     r8, [rbx + linked_list.vtable]
    call    [r8 + list_vtable.insert_before_node]
    pop     r8
    ret

FUNCTION _list_insert_after_node
    push    r8
    mov     r8, [rbx + linked_list.vtable]
    call    [r8 + list_vtable.insert_after_node]
    pop     r8
    ret

FUNCTION _list_remove_node
    push    r8
    mov     r8, [rbx + linked_list.vtable]
    call    [r8 + list_vtable.remove_node]
    pop     r8
    ret

FUNCTION _list_remove_node_at_head
    push    r8
    mov     r8, [rbx + linked_list.vtable]
    call    [r8 + list_vtable.remove_node_at_head]
    pop     r8
    ret

FUNCTION _list_remove_node_at_tail
    push    r8
    mov     r8, [rbx + linked_list.vtable]
    call    [r8 + list_vtable.remove_node_at_tail]
    pop     r8
    ret
