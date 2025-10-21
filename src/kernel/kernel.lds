/* ================================================================================================================= *
 * = Superbia toy operating system - (c) 2025+ Laurent Menten
 * ================================================================================================================= */

OUTPUT_FORMAT( elf64-x86-64 )

ENTRY( _kernel_entrypoint )

/* Define the program headers we want so the bootloader gives us the right */
/* MMU permissions; this also allows us to exert more control over the linking */
/* process. */

PHDRS
{
    limine_requests PT_LOAD;
    text            PT_LOAD;
    rodata          PT_LOAD;
    data            PT_LOAD;
}

SECTIONS
{
    /* We want to be placed in the topmost 2GiB of the address space, for optimisations */
    /* and because that is what the Limine spec mandates. */
    /* Any address in this region will do, but often 0xffffffff80000000 is chosen as */
    /* that is the beginning of the region. */

    . = 0xffffffff80000000;

    /* ============================================================================================================= *
     * = Limine requests PHDR ====================================================================================== *
     * ============================================================================================================= */

    .limine_requests :
    {
        PROVIDE_HIDDEN( __limine_header_start = . );
        KEEP(*(.limine_requests_start))
        KEEP(*(.limine_requests))
        KEEP(*(.limine_requests_end))
        PROVIDE_HIDDEN( __limine_header_end = . );
    } :limine_requests

    /* ============================================================================================================= *
     * = .text ===================================================================================================== *
     * ============================================================================================================= */

    . = ALIGN( CONSTANT( MAXPAGESIZE ) );

    .text :
    {
        PROVIDE_HIDDEN( __text_start = . );
        *(.text .text.*)
        PROVIDE_HIDDEN( __text_end = . );
    } :text

    /* ============================================================================================================= *
     * = .rodata =================================================================================================== *
     * ============================================================================================================= */

    . = ALIGN( CONSTANT( MAXPAGESIZE ) );

    .rodata :
    {
        PROVIDE_HIDDEN( __rodata_start = . );
        *(.rodata .rodata.*)
        PROVIDE_HIDDEN( __rodata_end = . );
    } :rodata

    /* ------------------------------------------------------------------------------------------------------------- */

    . = ALIGN(8);
    .kinit_array : ALIGN( 8 )
    {
        PROVIDE_HIDDEN( __kinit_array_start = . );
        KEEP( *( SORT_BY_NAME(.kinit .kinit.* ) ) )
        PROVIDE_HIDDEN( __kinit_array_end = . );
    } :rodata

    . = ALIGN( 8 );
    .kfini_array : ALIGN(8)
    {
        PROVIDE_HIDDEN( __kfini_array_start = . );
        KEEP( *( SORT_BY_NAME(.kfini .kfini.* ) ) )
        PROVIDE_HIDDEN( __kfini_array_end = . );
    } :rodata

    /* ------------------------------------------------------------------------------------------------------------- */

    .note.gnu.build-id : {
        *(.note.gnu.build-id)
    } :rodata

    /* ============================================================================================================= *
     * = .data ===================================================================================================== *
     * ============================================================================================================= */

    . = ALIGN( CONSTANT( MAXPAGESIZE ) );

    .data ALIGN( 16 ) :
    {
        PROVIDE_HIDDEN( __data_start = . );
        *(.data .data.*)
        PROVIDE_HIDDEN( __data_end = . );
    } :data

    PROVIDE( KERNEL_DATA_BUFFER_SIZE = 256K );
#   ASSERT( KERNEL_DATA_BUFFER_SIZE >= 64K, "KERNEL_DATA_BUFFER_SIZE should be >= 64K" );

    .bss ALIGN( 16 ) :
    {
        PROVIDE_HIDDEN( __bss_start = . );
        *(.bss .bss.*)
        *(COMMON)
        PROVIDE_HIDDEN( __bss_end = . );

        . = ALIGN( 4096 );
        PROVIDE_HIDDEN( __kernel_data_buffer_start = . );
        . = . + KERNEL_DATA_BUFFER_SIZE;
        PROVIDE_HIDDEN( __kernel_data_buffer_end = . );
    } :data

    /* ============================================================================================================= *
     * = Discarded  ================================================================================================ *
     * ============================================================================================================= */

    /DISCARD/ :
    {
        *(.eh_frame*)
        *(.note .note.*)
    }
}
