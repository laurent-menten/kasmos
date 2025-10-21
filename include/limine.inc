; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

%ifndef __KASMOS_LIMNE_INC__
%define __KASMOS_LIMNE_INC__

; ---------------------------------------------------------------------------------------------------------------------

%ifndef LIMINE_API_REVISION
    %warning "limine.inc: LIMINE_API_REVISION not defined, defaulting to 0"
    %assign LIMINE_API_REVISION 0
%endif

%if LIMINE_API_REVISION > 3
    %error "limine.inc: LIMINE_API_REVISION > 3 is unsupported"
%endif

; ---------------------------------------------------------------------------------------------------------------------

%define LIMINE_COMMON_MAGIC_LO 0xc7b1dd30df4c8b88
%define LIMINE_COMMON_MAGIC_HI 0x0a82e883a194f07b

; Requests marker macros (emit data where invoked)
%macro LIMINE_REQUESTS_START_MARKER 0
    dq 0xf6b8f4b39de7d1ae, 0xfab91a6940fcb9cf
    dq 0x785c6ed015d3e316, 0x181e920a7852b9d9
%endmacro

%macro LIMINE_REQUESTS_END_MARKER 0
    dq 0xadc0e0531bb10d03, 0x9572709f31764c62
%endmacro

; Historically used as delimiter too
%macro LIMINE_REQUESTS_DELIMITER 0
    LIMINE_REQUESTS_END_MARKER
%endmacro

; Base revision array emitter: pass N as argument
; Example: LIMINE_BASE_REVISION 0
%macro LIMINE_BASE_REVISION 1
    dq 0xf9562b2d5c95a6c8, 0x6a7b384944536bdc, %1
%endmacro

; ---------------------------------------------------------------------------------------------------------------------

; ===== Basic types / small structs ====================================================

; struct limine_uuid {
;   uint32_t a; uint16_t b; uint16_t c; uint8_t d[8];
; };
struc limine_uuid
    .a         resd 1
    .b         resw 1
    .c         resw 1
    .d         resb 8
endstruc

; ===== Media types ===================================================================
%define LIMINE_MEDIA_TYPE_GENERIC 0
%define LIMINE_MEDIA_TYPE_OPTICAL 1
%define LIMINE_MEDIA_TYPE_TFTP    2

; ===== struct limine_file =============================================================

; struct limine_file {
;   u64 revision; void* address; u64 size; char* path;
;   (API>=3: char* string) else (char* cmdline);
;   u32 media_type; u32 unused; u32 tftp_ip; u32 tftp_port;
;   u32 partition_index; u32 mbr_disk_id;
;   uuid gpt_disk_uuid, gpt_part_uuid, part_uuid;
; };
struc limine_file
    .revision          resq 1
    .address           resq 1
    .size              resq 1
    .path              resq 1
%if LIMINE_API_REVISION >= 3
    .string            resq 1
%else
    .cmdline           resq 1
%endif
    .media_type        resd 1
    .unused            resd 1
    .tftp_ip           resd 1
    .tftp_port         resd 1
    .partition_index   resd 1
    .mbr_disk_id       resd 1
    .gpt_disk_uuid     resb limine_uuid_size
    .gpt_part_uuid     resb limine_uuid_size
    .part_uuid         resb limine_uuid_size
endstruc

; ===== Bootloader info ================================================================

; #define LIMINE_BOOTLOADER_INFO_REQUEST { MAGIC..., 0xf55038d8e2a1202f, 0x279426fcf5f59740 }
%define LIMINE_BOOTLOADER_INFO_REQUEST_2 0xf55038d8e2a1202f
%define LIMINE_BOOTLOADER_INFO_REQUEST_3 0x279426fcf5f59740

struc limine_bootloader_info_response
    .revision  resq 1
    .name      resq 1
    .version   resq 1
endstruc

struc limine_bootloader_info_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== Executable command line ========================================================

%define LIMINE_EXECUTABLE_CMDLINE_REQUEST_2 0x4b161536e598651e
%define LIMINE_EXECUTABLE_CMDLINE_REQUEST_3 0xb390ad4a2f1f303a

struc limine_executable_cmdline_response
    .revision  resq 1
    .cmdline   resq 1
endstruc

struc limine_executable_cmdline_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== Firmware type =================================================================

%define LIMINE_FIRMWARE_TYPE_REQUEST_2 0x8c2f75d90bef28a8
%define LIMINE_FIRMWARE_TYPE_REQUEST_3 0x7045a4688eac00c3

%define LIMINE_FIRMWARE_TYPE_X86BIOS 0
%define LIMINE_FIRMWARE_TYPE_UEFI32  1
%define LIMINE_FIRMWARE_TYPE_UEFI64  2
%define LIMINE_FIRMWARE_TYPE_SBI     3

struc limine_firmware_type_response
    .revision      resq 1
    .firmware_type resq 1
endstruc

struc limine_firmware_type_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== Stack size ====================================================================

%define LIMINE_STACK_SIZE_REQUEST_2 0x224ef0460a8e8926
%define LIMINE_STACK_SIZE_REQUEST_3 0xe1cb0fc25f46ea3d

struc limine_stack_size_response
    .revision  resq 1
endstruc

struc limine_stack_size_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
    .stack_size resq 1
endstruc

; ===== HHDM ==========================================================================
%define LIMINE_HHDM_REQUEST_2 0x48dcf1cb8ad2b852
%define LIMINE_HHDM_REQUEST_3 0x63984e959a98244b

struc limine_hhdm_response
    .revision  resq 1
    .offset    resq 1
endstruc

struc limine_hhdm_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== Framebuffer ===================================================================

%define LIMINE_FRAMEBUFFER_REQUEST_2 0x9d5827dcd881dd75
%define LIMINE_FRAMEBUFFER_REQUEST_3 0xa3148604f6fab11b

%define LIMINE_FRAMEBUFFER_RGB 1

struc limine_video_mode
    .pitch           resq 1
    .width           resq 1
    .height          resq 1
    .bpp             resw 1
    .memory_model    resb 1
    .red_mask_size   resb 1
    .red_mask_shift  resb 1
    .green_mask_size resb 1
    .green_mask_shift resb 1
    .blue_mask_size  resb 1
    .blue_mask_shift resb 1
endstruc

struc limine_framebuffer
    .address         resq 1
    .width           resq 1
    .height          resq 1
    .pitch           resq 1
    .bpp             resw 1
    .memory_model    resb 1
    .red_mask_size   resb 1
    .red_mask_shift  resb 1
    .green_mask_size resb 1
    .green_mask_shift resb 1
    .blue_mask_size  resb 1
    .blue_mask_shift resb 1
    .unused          resb 7
    .edid_size       resq 1
    .edid            resq 1
    ; Response rev 1
    .mode_count      resq 1
    .modes           resq 1 ; pointer to array of pointers
endstruc

struc limine_framebuffer_response
    .revision         resq 1
    .framebuffer_count resq 1
    .framebuffers     resq 1 ; pointer to array of pointers
endstruc

struc limine_framebuffer_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== Terminal (deprecated) =========================================================

%define LIMINE_TERMINAL_REQUEST_2 0xc8ac59310c2b0844
%define LIMINE_TERMINAL_REQUEST_3 0xa68d0c7265d38878

%define LIMINE_TERMINAL_CB_DEC            10
%define LIMINE_TERMINAL_CB_BELL           20
%define LIMINE_TERMINAL_CB_PRIVATE_ID     30
%define LIMINE_TERMINAL_CB_STATUS_REPORT  40
%define LIMINE_TERMINAL_CB_POS_REPORT     50
%define LIMINE_TERMINAL_CB_KBD_LEDS       60
%define LIMINE_TERMINAL_CB_MODE           70
%define LIMINE_TERMINAL_CB_LINUX          80

%define LIMINE_TERMINAL_CTX_SIZE     -1
%define LIMINE_TERMINAL_CTX_SAVE     -2
%define LIMINE_TERMINAL_CTX_RESTORE  -3
%define LIMINE_TERMINAL_FULL_REFRESH -4

; Response rev 1 OOB
%define LIMINE_TERMINAL_OOB_OUTPUT_GET    -10
%define LIMINE_TERMINAL_OOB_OUTPUT_SET    -11

%define LIMINE_TERMINAL_OOB_OUTPUT_OCRNL  (1 << 0)
%define LIMINE_TERMINAL_OOB_OUTPUT_OFDEL  (1 << 1)
%define LIMINE_TERMINAL_OOB_OUTPUT_OFILL  (1 << 2)
%define LIMINE_TERMINAL_OOB_OUTPUT_OLCUC  (1 << 3)
%define LIMINE_TERMINAL_OOB_OUTPUT_ONLCR  (1 << 4)
%define LIMINE_TERMINAL_OOB_OUTPUT_ONLRET (1 << 5)
%define LIMINE_TERMINAL_OOB_OUTPUT_ONOCR  (1 << 6)
%define LIMINE_TERMINAL_OOB_OUTPUT_OPOST  (1 << 7)

; typedefs -> pointers (modeled as qword fields in structs below)

struc limine_terminal
    .columns     resq 1
    .rows        resq 1
    .framebuffer resq 1
endstruc

struc limine_terminal_response
    .revision     resq 1
    .terminal_count resq 1
    .terminals    resq 1  ; ** pointer to array of pointers
    .write        resq 1  ; function pointer
endstruc

struc limine_terminal_request
    .id           resq 4
    .revision     resq 1
    .response     resq 1
    .callback     resq 1  ; function pointer
endstruc

; ===== Paging mode ===================================================================

%define LIMINE_PAGING_MODE_REQUEST_2 0x95c1a0edab0944cb
%define LIMINE_PAGING_MODE_REQUEST_3 0xa4e5cb3842f7488a

; x86-64
%define LIMINE_PAGING_MODE_X86_64_4LVL 0
%define LIMINE_PAGING_MODE_X86_64_5LVL 1
%define LIMINE_PAGING_MODE_MIN     LIMINE_PAGING_MODE_X86_64_4LVL
%define LIMINE_PAGING_MODE_DEFAULT LIMINE_PAGING_MODE_X86_64_4LVL

struc limine_paging_mode_response
    .revision  resq 1
    .mode      resq 1
endstruc

struc limine_paging_mode_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
    .mode      resq 1
    .max_mode  resq 1
    .min_mode  resq 1
endstruc

; ===== 5-level paging (deprecated) ===================================================

%define LIMINE_5_LEVEL_PAGING_REQUEST_2 0x94469551da9b3192
%define LIMINE_5_LEVEL_PAGING_REQUEST_3 0xebe5e86db7382888

struc limine_5_level_paging_response
    .revision  resq 1
endstruc

struc limine_5_level_paging_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== MP / SMP ======================================================================

%if LIMINE_API_REVISION >= 1
    %define LIMINE_MP_REQUEST_2 0x95a67b819a1b857e
    %define LIMINE_MP_REQUEST_3 0xa0b61b723b6a73e0
    %define LIMINE_MP_X2APIC (1 << 0)
%else
    %define LIMINE_SMP_REQUEST_2 0x95a67b819a1b857e
    %define LIMINE_SMP_REQUEST_3 0xa0b61b723b6a73e0
    %define LIMINE_SMP_X2APIC (1 << 0)
%endif

; x86-64 layout
struc limine_mp_info
    .processor_id  resd 1
    .lapic_id      resd 1
    .reserved      resq 1
    .goto_address  resq 1   ; function pointer
    .extra_argument resq 1
endstruc

struc limine_mp_response
    .revision      resq 1
    .flags         resd 1
    .bsp_lapic_id  resd 1
    .cpu_count     resq 1
    .cpus          resq 1   ; pointer to array of pointers to limine_mp_info
endstruc

struc limine_mp_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
    .flags     resq 1
endstruc

; ===== Memory map ====================================================================

%define LIMINE_MEMMAP_REQUEST_2 0x67cf3d9d378a806f
%define LIMINE_MEMMAP_REQUEST_3 0xe304acdfc50c3c62

%define LIMINE_MEMMAP_USABLE                  0
%define LIMINE_MEMMAP_RESERVED                1
%define LIMINE_MEMMAP_ACPI_RECLAIMABLE        2
%define LIMINE_MEMMAP_ACPI_NVS                3
%define LIMINE_MEMMAP_BAD_MEMORY              4
%if LIMINE_API_REVISION >= 2
    %define LIMINE_MEMMAP_EXECUTABLE_AND_MODULES 6
%else
    %define LIMINE_MEMMAP_KERNEL_AND_MODULES     6
%endif
%define LIMINE_MEMMAP_FRAMEBUFFER             7

struc limine_memmap_entry
    .base    resq 1
    .length  resq 1
    .type    resq 1
endstruc

struc limine_memmap_response
    .revision    resq 1
    .entry_count resq 1
    .entries     resq 1 ; pointer to array of pointers
endstruc

struc limine_memmap_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== Entry point ===================================================================

%define LIMINE_ENTRY_POINT_REQUEST_2 0x13d86c035a1cd3e1
%define LIMINE_ENTRY_POINT_REQUEST_3 0x2b0caa89d8f3026a

struc limine_entry_point_response
    .revision  resq 1
endstruc

struc limine_entry_point_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
    .entry     resq 1 ; function pointer
endstruc

; ===== Executable file / Kernel file =================================================

%if LIMINE_API_REVISION >= 2
    %define LIMINE_EXECUTABLE_FILE_REQUEST_2 0xad97e90e83f1ed67
    %define LIMINE_EXECUTABLE_FILE_REQUEST_3 0x31eb5d1c5ff23b69
    struc limine_executable_file_response
        .revision         resq 1
        .executable_file  resq 1
    endstruc
    struc limine_executable_file_request
        .id        resq 4
        .revision  resq 1
        .response  resq 1
    endstruc
%else
    %define LIMINE_KERNEL_FILE_REQUEST_2 0xad97e90e83f1ed67
    %define LIMINE_KERNEL_FILE_REQUEST_3 0x31eb5d1c5ff23b69
    struc limine_kernel_file_response
        .revision    resq 1
        .kernel_file resq 1
    endstruc
    struc limine_kernel_file_request
        .id        resq 4
        .revision  resq 1
        .response  resq 1
    endstruc
%endif

; ===== Modules =======================================================================

%define LIMINE_MODULE_REQUEST_2 0x3e7e279702be32af
%define LIMINE_MODULE_REQUEST_3 0xca1c4f3bd1280cee

%define LIMINE_INTERNAL_MODULE_REQUIRED  (1 << 0)
%define LIMINE_INTERNAL_MODULE_COMPRESSED (1 << 1)

struc limine_internal_module
    .path    resq 1
%if LIMINE_API_REVISION >= 3
    .string  resq 1
%else
    .cmdline resq 1
%endif
    .flags   resq 1
endstruc

struc limine_module_response
    .revision     resq 1
    .module_count resq 1
    .modules      resq 1 ; pointer to array of pointers (limine_file**)
endstruc

struc limine_module_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
    ; rev 1
    .internal_module_count resq 1
    .internal_modules      resq 1 ; pointer to array of pointers
endstruc

; ===== RSDP ==========================================================================
%define LIMINE_RSDP_REQUEST_2 0xc5e77b6b397e7b43
%define LIMINE_RSDP_REQUEST_3 0x27637845accdcf3c

struc limine_rsdp_response
    .revision resq 1
%if LIMINE_API_REVISION >= 1
    .address  resq 1
%else
    .address  resq 1
%endif
endstruc

struc limine_rsdp_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== SMBIOS ========================================================================

%define LIMINE_SMBIOS_REQUEST_2 0x9e9046f11e095391
%define LIMINE_SMBIOS_REQUEST_3 0xaa4a520fefbde5ee

struc limine_smbios_response
    .revision resq 1
%if LIMINE_API_REVISION >= 1
    .entry_32 resq 1
    .entry_64 resq 1
%else
    .entry_32 resq 1
    .entry_64 resq 1
%endif
endstruc

struc limine_smbios_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== EFI system table ===============================================================

%define LIMINE_EFI_SYSTEM_TABLE_REQUEST_2 0x5ceba5163eaaf6d6
%define LIMINE_EFI_SYSTEM_TABLE_REQUEST_3 0x0a6981610cf65fcc

struc limine_efi_system_table_response
    .revision resq 1
%if LIMINE_API_REVISION >= 1
    .address  resq 1
%else
    .address  resq 1
%endif
endstruc

struc limine_efi_system_table_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== EFI memory map =================================================================

%define LIMINE_EFI_MEMMAP_REQUEST_2 0x7df62a431d6872d5
%define LIMINE_EFI_MEMMAP_REQUEST_3 0xa4fcdfb3e57306c8

struc limine_efi_memmap_response
    .revision     resq 1
    .memmap       resq 1
    .memmap_size  resq 1
    .desc_size    resq 1
    .desc_version resq 1
endstruc

struc limine_efi_memmap_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== Date at boot / Boot time ======================================================

%if LIMINE_API_REVISION >= 3
    %define LIMINE_DATE_AT_BOOT_REQUEST_2 0x502746e184c088aa
    %define LIMINE_DATE_AT_BOOT_REQUEST_3 0xfbc5ec83e6327893
    struc limine_date_at_boot_response
        .revision  resq 1
        .timestamp resq 1   ; int64
    endstruc
    struc limine_date_at_boot_request
        .id        resq 4
        .revision  resq 1
        .response  resq 1
    endstruc
%else
    %define LIMINE_BOOT_TIME_REQUEST_2 0x502746e184c088aa
    %define LIMINE_BOOT_TIME_REQUEST_3 0xfbc5ec83e6327893
    struc limine_boot_time_response
        .revision  resq 1
        .boot_time resq 1   ; int64
    endstruc
    struc limine_boot_time_request
        .id        resq 4
        .revision  resq 1
        .response  resq 1
    endstruc
%endif

; ===== Executable / Kernel address ===================================================

%if LIMINE_API_REVISION >= 2
    %define LIMINE_EXECUTABLE_ADDRESS_REQUEST_2 0x71ba76863cc55f63
    %define LIMINE_EXECUTABLE_ADDRESS_REQUEST_3 0xb2644a48c516a487
    struc limine_executable_address_response
        .revision     resq 1
        .physical_base resq 1
        .virtual_base  resq 1
    endstruc
    struc limine_executable_address_request
        .id        resq 4
        .revision  resq 1
        .response  resq 1
    endstruc
%else
    %define LIMINE_KERNEL_ADDRESS_REQUEST_2 0x71ba76863cc55f63
    %define LIMINE_KERNEL_ADDRESS_REQUEST_3 0xb2644a48c516a487
    struc limine_kernel_address_response
        .revision     resq 1
        .physical_base resq 1
        .virtual_base  resq 1
    endstruc
    struc limine_kernel_address_request
        .id        resq 4
        .revision  resq 1
        .response  resq 1
    endstruc
%endif

; ===== DTB ===========================================================================
%define LIMINE_DTB_REQUEST_2 0xb40ddb48fb54bac7
%define LIMINE_DTB_REQUEST_3 0x545081493f81ffb7

struc limine_dtb_response
    .revision resq 1
    .dtb_ptr  resq 1
endstruc

struc limine_dtb_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== RISC-V BSP HartID (kept for completeness) =====================================
%define LIMINE_RISCV_BSP_HARTID_REQUEST_2 0x1369359f025525f9
%define LIMINE_RISCV_BSP_HARTID_REQUEST_3 0x2ff2a56178391bb6

struc limine_riscv_bsp_hartid_response
    .revision  resq 1
    .bsp_hartid resq 1
endstruc

struc limine_riscv_bsp_hartid_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== Bootloader performance =========================================================
%define LIMINE_BOOTLOADER_PERFORMANCE_REQUEST_2 0x6b50ad9bf36d13ad
%define LIMINE_BOOTLOADER_PERFORMANCE_REQUEST_3 0xdc4c7e88fc759e17

struc limine_bootloader_performance_response
    .revision  resq 1
    .reset_usec resq 1
    .init_usec  resq 1
    .exec_usec  resq 1
endstruc

struc limine_bootloader_performance_request
    .id        resq 4
    .revision  resq 1
    .response  resq 1
endstruc

; ===== Convenience macros to stamp a request header ==================================
; These help you declare a request instance quickly:
; Usage example:
;   my_req:
;       LIMINE_REQUEST_HEADER LIMINE_BOOTLOADER_INFO_REQUEST_2, LIMINE_BOOTLOADER_INFO_REQUEST_3
;       dq 0                  ; revision
;       dq 0                  ; response pointer (bootloader will fill)
%macro LIMINE_REQUEST_HEADER 2
    dq LIMINE_COMMON_MAGIC_LO, LIMINE_COMMON_MAGIC_HI
    dq %1, %2
%endmacro

%endif ;__KASMOS_LIMNE_INC__