# =====================================================================================================================
# === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
# =====================================================================================================================

export KASMOS_DIR = $(abspath .)

include $(KASMOS_DIR)/Makefile.rules

all:
	$(MAKE) -C src/kernel

clean:
	$(MAKE) -> src/kernel clean

# =====================================================================================================================
# = 
# =====================================================================================================================

iso: all
	mkdir -p $(ISO_TMPDIR)/boot
	cp $(KERNEL_FILE) $(ISO_TMPDIR)/boot/
	cp $(KERNEL_DBG_FILE) $(ISO_TMPDIR)/boot/
	mkdir -p $(ISO_TMPDIR)/boot/limine
	cp $(LIMINE_IMAGES)/limine-bios.sys $(ISO_TMPDIR)/boot/limine/
	cp $(LIMINE_IMAGES)/limine-bios-cd.bin $(ISO_TMPDIR)/boot/limine/
	cp $(LIMINE_IMAGES)/limine-uefi-cd.bin $(ISO_TMPDIR)/boot/limine/
	mkdir -p $(ISO_TMPDIR)/EFI/BOOT
	cp $(LIMINE_IMAGES)/BOOTX64.EFI $(ISO_TMPDIR)/EFI/BOOT/
	cp $(KASMOS_DIR)/limine.conf $(ISO_TMPDIR)/
	xorriso -as mkisofs -iso-level 3 \
		-R -J -joliet-long \
		-b boot/limine/limine-bios-cd.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot \
		-e boot/limine/limine-uefi-cd.bin -no-emul-boot -isohybrid-gpt-basdat \
        -V "KASMOS" \
        -o $(ISO_FILE) $(ISO_TMPDIR)
	rm -r $(ISO_TMPDIR)

# =====================================================================================================================
# = 
# =====================================================================================================================

GDB_REMOTE_PORT = 6666

CPU_CONFIG = -machine q35,accel=tcg \
  -cpu qemu64,+sse2,+sse4.2,+xsave,+xsaveopt,+fsgsbase,+rdtscp,+smep,+smap,+umip,+cx16,+popcnt,+aes,+pclmulqdq \
  -smp 8 -m 1024M

DBG_CONFIG = -monitor none \
	-chardev socket,id=ser0,host=127.0.0.1,port=6667,server=on,wait=on \
	-serial chardev:ser0 \
	-chardev socket,id=dbg0,host=127.0.0.1,port=6668,server=on,wait=on \
	-device isa-debugcon,iobase=0xe9,chardev=dbg0

boot_test: iso
	clear
	$(QEMU_EXE) \
		$(CPU_CONFIG) \
		$(DBG_CONFIG) \
		-cdrom $(ISO_FILE) \
		-boot d \
		-no-reboot -no-shutdown 

# ---------------------------------------------------------------------------------------------------------------------

boot_debug_test: iso
	clear
	$(QEMU_EXE) \
		$(CPU_CONFIG) \
		$(DBG_CONFIG) \
		-cdrom $(ISO_FILE) \
		-boot d \
		-gdb tcp::$(GDB_REMOTE_PORT) -S \
		-no-reboot -no-shutdown 

gdb: iso
	gdb -ex "target remote :$(GDB_REMOTE_PORT)" \
		-ex "break _kernel_entrypoint" \
		-ex "continue" \
		$(KERNEL_FILE)

# =====================================================================================================================
# = 
# =====================================================================================================================

install-3rd-party-tools: install-llvm install-gdb install-nasm install-qemu install-limine

# ---------------------------------------------------------------------------------------------------------------------

LLVM_PREFIX = $(LLVM_DIR)

LLVM_CONFIG = -S llvm -B build -G "Unix Makefiles" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(LLVM_PREFIX)" \
	-DLLVM_TARGETS_TO_BUILD="X86" \
	-DLLVM_ENABLE_PROJECTS="clang;lld;lldb" \
	-DLLVM_ENABLE_RUNTIMES=compiler-rt \
	-DLLVM_ENABLE_RTTI=ON \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INCLUDE_DOCS=OFF \
	-DLLVM_ENABLE_ASSERTIONS=ON \
	-DCMAKE_INSTALL_RPATH="$(LLVM_PREFIX)/lib" \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
	-DCMAKE_C_COMPILER_LAUNCHER=ccache  \
	-DCMAKE_CXX_COMPILER_LAUNCHER=ccache

install-llvm:
	mkdir -p $(KASMOS_3RD_PARTY_TOOLS_DIR)
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR) && git clone https://github.com/llvm/llvm-project.git )
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR)/llvm-project && cmake $(LLVM_CONFIG) )
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/llvm-project/build
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/llvm-project/build install

remove-llvm:
	-rm -f -r $(KASMOS_3RD_PARTY_TOOLS_DIR)/llvm-project
	-rm -f -r $(LLVM_DIR)

reinstall-llvm: remove-llvm install-llvm

# ---------------------------------------------------------------------------------------------------------------------

GDB_PREFIX = $(GDB_DIR)

GDB_CONFIG = --prefix=$(GDB_PREFIX)

install-gdb:
	mkdir -p $(KASMOS_3RD_PARTY_TOOLS_DIR)
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR) && git clone https://sourceware.org/git/binutils-gdb.git )
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR)/binutils-gdb && mkdir build && cd build && ../configure $(GDB_CONFIG) )
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/binutils-gdb/build
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/binutils-gdb/build install

remove-gdb:
	-rm -f -r $(KASMOS_3RD_PARTY_TOOLS_DIR)/binutils-gdb
	-rm -f -r $(GDB_DIR)

reinstall-gdb: remove-gdb install-gdb

# ---------------------------------------------------------------------------------------------------------------------

NASM_PREFIX = $(NASM_DIR)

NASM_CONFIG = --prefix=$(NASM_PREFIX)


install-nasm:
	mkdir -p $(KASMOS_3RD_PARTY_TOOLS_DIR)
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR) && git clone https://github.com/netwide-assembler/nasm.git )
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR)/nasm && sh autogen.sh )
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR)/nasm && mkdir build && cd build && ../configure $(NASM_CONFIG) )
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR)/nasm/build && make manpages && cp *.1 ..)
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/nasm/build
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/nasm/build install

remove-nasm:
	-rm -f -r $(KASMOS_3RD_PARTY_TOOLS_DIR)/nasm
	-rm -f -r $(NASM_DIR)

reinstall-nasm: remove-nasm install-nasm

# ---------------------------------------------------------------------------------------------------------------------

QEMU_PREFIX = $(QEMU_DIR)

QEMU_CONFIG = --prefix=$(QEMU_PREFIX) --target-list=x86_64-softmmu --enable-debug

install-qemu:
	mkdir -p $(KASMOS_3RD_PARTY_TOOLS_DIR)
#	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR) && git clone https://gitlab.com/qemu-project/qemu )
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR)/qemu && mkdir build && cd build && ../configure $(QEMU_CONFIG) )
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/qemu/build
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/qemu/build install

remove-qemu:
	-rm -f -r $(KASMOS_3RD_PARTY_TOOLS_DIR)/qemu
	-rm -f -r $(QEMU_DIR)

reinstall-qemu: remove-qemu install-qemu

# ---------------------------------------------------------------------------------------------------------------------

LIMINE_PREFIX = $(LIMINE_DIR)

LIMINE_CONFIG = --prefix=$(LIMINE_PREFIX) \
	--enable-bios-cd \
	--enable-bios-pxe \
	--enable-bios \
	--enable-uefi-ia32 \
	--enable-uefi-x86-64 \
	--enable-uefi-cd

install-limine: export PATH := $(PATH):$(NASM_BIN_DIR)

install-limine:
	mkdir -p $(KASMOS_3RD_PARTY_TOOLS_DIR)
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR) && git clone https://github.com/limine-bootloader/limine.git )
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR)/limine && ./bootstrap )
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR)/limine && mkdir build && cd build && TOOLCHAIN_FOR_TARGET= ../configure $(LIMINE_CONFIG) )
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/limine/build
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/limine/build install

remove-limine:
	-rm -f -r $(KASMOS_3RD_PARTY_TOOLS_DIR)/limine
	-rm -f -r $(LIMINE_DIR)

reinstall-limine: remove-limine install-limine
