; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     x64
	bits    64

	%include "lib/list.inc"

	extern vdebug_write_string
	extern vdebug_write_word

; =====================================================================================================================
; = 
; =====================================================================================================================

;	rbx < list

FUNCTION _list_debug_dump
	push	rax
	push	rcx
	push	rsi

	mov		rax, rbx
	mov		rcx, 16
	call	vdebug_write_word

	mov     rsi, text_0
	call    vdebug_write_string

	mov		rax, [rbx + linked_list.head]
	mov		rcx, 16
	call	vdebug_write_word

	mov     rsi, text_1
	call    vdebug_write_string

	mov		rax, [rbx + linked_list.tail]
	mov		rcx, 16
	call	vdebug_write_word

	mov     rsi, text_1b
	call    vdebug_write_string

	mov		rax, [rbx + linked_list.count]
	mov		rcx, 4
	call	vdebug_write_word

	mov     rsi, text_2
	call    vdebug_write_string

	mov		rax, [rbx + linked_list.head]

.next:
	test	rax, rax
	jz		.done

	mov		rcx, 16
	call	vdebug_write_word

	mov     rsi, text_3
	call    vdebug_write_string

	mov		rax,  [rax + linked_list_node.next]
	jmp		.next

.done:
	mov     rsi, text_4
	call    vdebug_write_string

	pop		rsi
	pop		rcx
	pop		rax
    ret
ENDFUNCTION

RODATA text_0
	db	' : (h=', 0

RODATA text_1
	db	', t=', 0

RODATA text_1b
	db	', c=', 0

RODATA text_2
	db	') ', 0

RODATA text_3
	db	' - ', 0

RODATA text_4
	db	10, 13, 0
