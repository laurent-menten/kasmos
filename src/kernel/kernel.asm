; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

	cpu     X64
	bits    64

    %include "limine.inc"

; =====================================================================================================================
; = Limine ============================================================================================================
; =====================================================================================================================

	section .limine_requests_start

	LIMINE_REQUESTS_START_MARKER

	section .limine_requests

	LIMINE_BASE_REVISION 3

    global _limine_mp_request
    global _limine_mp_request.response
_limine_mp_request:
	istruc limine_mp_request
		LIMINE_REQUEST_HEADER                   LIMINE_MP_REQUEST_2, LIMINE_MP_REQUEST_3
.response:
		at limine_mp_request.response,          dq 0
		at limine_mp_request.flags,             dq 0
	iend

    global _limine_framebuffer_request
    global _limine_framebuffer_request.response
_limine_framebuffer_request:
	istruc limine_framebuffer_request
		LIMINE_REQUEST_HEADER                   LIMINE_FRAMEBUFFER_REQUEST_2, LIMINE_FRAMEBUFFER_REQUEST_3
.response:
		at limine_framebuffer_request.response, dq 0
	iend

	section .limine_requests_end

	LIMINE_REQUESTS_END_MARKER
   
; =====================================================================================================================
; = 
; =====================================================================================================================

DATA _kasmos_master_list
	istruc kasmos_master_list
        at .panic_code,     dq  PANIC_CODE_NO_ERROR
	iend
