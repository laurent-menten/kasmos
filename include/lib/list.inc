; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

%ifndef __LIST_INC__
%define __LIST_INC__

    %include "lib/list_def.inc"

    extern _list_init
    extern _list_is_empty
    extern _list_add_node_at_head
    extern _list_add_node_at_tail
    extern _list_insert_after_node
    extern _list_insert_before_node
    extern _list_remove_node
    extern _list_remove_node_at_head
    extern _list_remove_node_at_head

    extern _list_init_node

%endif ;__LIST_INC__
