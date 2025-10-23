; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

%ifndef __X86_64_INC__
%define __X86_64_INC__

	cpu     X64
	bits    64

; =====================================================================================================================
; =
; =====================================================================================================================

STRUCT gdt_descriptor_64
	.gdt_size							resw	1				; ? * 16 = ?
	.gdt_address						resq	1
ENDSTRUCT

; =====================================================================================================================
; =
; =====================================================================================================================

STRUCT gate_descriptor_64
	.offset_0_15        resw    1
	.selector           resw    1
	.ist                resb    1                           ; reserved:5 IST:3 
	.type               resb    1                           ; P:1 DPL:2 0 type:4
	.offset_16_31       resw    1
	.offset_31_63       resd    1
	.reserved           resd    1
ENDSTRUCT

GATE_PRESENT            equ     0b1_00_0_0000
GATE_DPL0               equ     0b0_00_0_0000
GATE_DPL3               equ     0b0_11_0_0000
GATE_INTERRUPT          equ     0b0_00_0_1110
GATE_TRAP               equ     0b0_00_0_1111

; =====================================================================================================================
; =
; =====================================================================================================================

STRUCT idt_descriptor_64
	.idt_size							resw	1				; 256 * 16 = 4096
	.idt_address						resq	1
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

STRUCT idt_64
	.divide_error                   resq    2               ;  0 #DE    Fault
	.debug_exception                resq    2               ;  1 #DB    Trap
	.nmi                            resq    2               ;  2        Interrupt
	.breakpoint                     resq    2               ;  3 #BP    Trap
	.overflow                       resq    2               ;  4 #OF    Trap
	.bound_range_exceeded           resq    2               ;  5 #BR    Fault
	.invalid_opcode                 resq    2               ;  6 #UD    Fault
	.no_fpu                         resq    2               ;  7 #NM    Fault
	.double_fault                   resq    2               ;  8 #DF    Abort           * error code
	.fpu_overrun                    resq    2               ;  9        -
	.invalid_tss                    resq    2               ; 10 #TS    Fault           * error code    
	.segment_not_present            resq    2               ; 11 #NP    Fault           * error code
	.stack_segment_fault            resq    2               ; 12 #SS    Fault           * error code
	.general_protection             resq    2               ; 13 #GP    Fault           * error code
	.page_fault                     resq    2               ; 14 #PF    Fault           * error code
	.reserved_15                    resq    2               ; 15        Fault
	.fpu_error                      resq    2               ; 16 #MF    Fault
	.alignment_check                resq    2               ; 17 #AC    Fault           * error code
	.machine_check                  resq    2               ; 18 #MC    Abort
	.simd_exceptions                resq    2               ; 19 #XM    Fault
	.virtualization_exception       resq    2               ; 20 #VE    Fault
	.control_protection_exception   resq    2               ; 21 #CP    Fault           * error code
	.reserved_22                    resq    2               ; 22        -
	.reserved_23                    resq    2               ; 23        -
	.reserved_24                    resq    2               ; 24        -
	.reserved_25                    resq    2               ; 25        -
	.reserved_26                    resq    2               ; 26        -
	.reserved_27                    resq    2               ; 27        -
	.reserved_28                    resq    2               ; 28        -
	.reserved_29                    resq    2               ; 29        -
	.reserved_30                    resq    2               ; 30        -
	.reserved_31                    resq    2               ; 31        -
	.user                           resq    (256-32) * 2    ; 32+       Interrupt
ENDSTRUCT

; =====================================================================================================================
; =
; =====================================================================================================================

STRUCT tss_descriptor_64
	.limit_0_15						resw	1
	.base_0_15						resw	1
	.base_16_23						resb	1
	.type_limite_16_19				resb	1
	.access							resb	1	
	.base_24_31						resb	1
	.base_32_63						resd	1
	.reserved						resd	1
ENDSTRUCT

; ---------------------------------------------------------------------------------------------------------------------

STRUCT tss_64
	.reserved_0						resd	1
	.rsp0							resq	1
	.rsp1							resq	1
	.rsp2							resq	1
	.reserved_1C					resq	1
	.ist1							resq	1
	.ist2							resq	1
	.ist3							resq	1
	.ist4							resq	1
	.ist5							resq	1
	.ist6							resq	1
	.ist7							resq	1
	.reserved_5C					resq	1
	.reserved_64					resw	1
	.iopb							resw	1
ENDSTRUCT

; =====================================================================================================================
; =
; =====================================================================================================================

IA32_FS_BASE				equ		0xC0000100
IA32_GS_BASE				equ		0xC0000101
IA32_KERNEL_GS_BASE			equ		0xC0000102

%endif ;__X86_64_INC__
