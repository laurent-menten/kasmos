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
;   rax > is empty

FUNCTION __list_is_empty_unlocked
    mov     rax, [rbx + linked_list.head]
    and     rax, rax
    setz    rax
    ret

FUNCTION __list_is_empty_locked
    jmp     __list_is_empty_unlocked
