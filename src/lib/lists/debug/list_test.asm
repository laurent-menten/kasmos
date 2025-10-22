; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

	extern _list_init
	extern _list_add_node_at_head
	extern _list_add_node_at_tail
	extern _list_insert_before_node
	extern _list_insert_after_node
	extern _list_remove_node
	extern _list_remove_node_at_head
	extern _list_remove_node_at_tail
	extern _list_debug_dump

; =====================================================================================================================
; = 
; =====================================================================================================================

FUNCTION _list_test
	push	rax
	push	rbx
	push	rsi

	mov		rax, LL_UNLOCKED_ACCESS
	mov		rbx, list_001
	call	_list_init
	call 	_list_debug_dump

	mov		rbx, list_001
	mov		rsi, node_001_001
	call	_list_add_node_at_head
	call 	_list_debug_dump

	mov		rbx, list_001
	mov		rsi, node_001_004
	call	_list_add_node_at_tail
	call 	_list_debug_dump

	mov		rbx, list_001
	mov		rsi, node_001_003
	mov		rdi, node_001_004
	call	_list_insert_before_node
	call 	_list_debug_dump

	mov		rbx, list_001
	mov		rsi, node_001_002
	mov		rdi, node_001_001
	call	_list_insert_after_node
	call 	_list_debug_dump

	mov		rbx, list_001
	mov		rsi, node_001_003
	call	_list_remove_node
	call 	_list_debug_dump

	mov		rbx, list_001
	call	_list_remove_node_at_head
	call 	_list_debug_dump

	mov		rbx, list_001
	call	_list_remove_node_at_tail
	call 	_list_debug_dump

	pop		rsi
	pop		rbx
	pop		rax
    ret

DATA list_001
	istruc linked_list
	iend

DATA node_001_001
	istruc linked_list_node
	iend

DATA node_001_002
	istruc linked_list_node
	iend

DATA node_001_003
	istruc linked_list_node
	iend

DATA node_001_004
	istruc linked_list_node
	iend
