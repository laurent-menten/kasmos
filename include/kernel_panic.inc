; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

%ifndef __KERNEL_PANIC_INC__
%define __KERNEL_PANIC_INC__

	extern _kasmos_master_list
	extern _kernel_panic

%macro KERNEL_PANIC 1
	mov     dword [abs _kasmos_master_list + kasmos_master_list.panic_code ], (%1) & 0xFFFF_FFFF
	mov     dword [abs _kasmos_master_list + kasmos_master_list.panic_code + 4 ], (%1) >> 32
	jmp     _kernel_panic
%endmacro

%endif ; __KERNEL_PANIC_INC__
