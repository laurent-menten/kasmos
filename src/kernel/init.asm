; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

    cpu     x64
    bits    64

; =====================================================================================================================
; = kinit_run_all =====================================================================================================
; =====================================================================================================================
;
; Loop through the kinit array and execute the registered functions.
;
;   In:     /
;
;   Out:    /
;

    extern __kinit_array_start
    extern __kinit_array_end

FUNCTION kinit_run_all
    push    rsi

    mov     rsi, __kinit_array_start

.loop:
    cmp     rsi, __kinit_array_end
    jae     .done


    push    rsi
    call    [rsi]
    pop     rsi

    add     rsi, 8
    jmp     .loop

.done:
    pop     rsi
    ret

; =====================================================================================================================
; = kfini_run_all
; =====================================================================================================================
;
; Loop through the kfini array in reverse order and execute the registered functions.
;
;   In:     /
;
;   Out:    /
;

    extern __kfini_array_start
    extern __kfini_array_end

FUNCTION kfini_run_all
    push    rsi

    mov     rsi, __kfini_array_end

.loop:
    sub     rsi, 8
    cmp     rsi, __kfini_array_start
    jb      .done

    push    rsi
    call    [rsi]
    pop     rsi

    jmp     .loop

.done:
    pop     rsi
    ret
