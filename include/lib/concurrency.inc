; =====================================================================================================================
; === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
; =====================================================================================================================

%ifndef __CONCURRENCY_INC__
%define __CONCURRENCY_INC__

	%include "concurrency_def.inc"

	extern _spin_lock_acquire
	extern _spin_lock_release

	extern _hybrid_spin_lock_acquire
	extern _hybrid_spin_lock_release

	extern _ticket_lock_acquire
	extern _ticket_lock_release

	extern _seq_lock_write_lock
	extern _seq_lock_write_unlock
	extern _seq_lock_read_begin
	extern _seq_lock_read_retry

	extern _mcs_lock_acquire
	extern _mcs_lock_try_acquire
	extern _mcs_lock_release

	extern _rw_read_lock
	extern _rw_read_unlock
	extern _rw_write_lock
	extern _rw_write_unlock

	extern _mutex_init
	extern _mutex_lock
	extern _mutex_unlock

	extern _semaphore_init
	extern _semaphore_down
	extern _semaphore_up

%endif ;__CONCURRENCY_INC__
