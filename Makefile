# =====================================================================================================================
# === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
# =====================================================================================================================

export KASMOS_DIR = $(abspath .)

include $(KASMOS_DIR)/Makefile.rules

all:
	$(MAKE) -C src/lib
	$(MAKE) -C src/kernel

clean:
	$(MAKE) -C src/lib clean
	$(MAKE) -C src/kernel clean
	-rm -r $(KASMOS_BUILD_DIR)
	-rm $(ISO_FILE)

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

run: iso
	$(BOCHS_EXE) -q -f kasmos.bochsrc

debug: iso
	$(BOCHS_EXE) -dbg_gui -q -f kasmos.bochsrc

# =====================================================================================================================
# = 
# =====================================================================================================================

install-3rd-party-tools: install-llvm install-nasm install-bochs install-limine

clean-3rd-party-tools: clean-llvm clean-nasm clean-bochs clean-limine

remove-3rd-party-tools: remove-llvm remove-nasm remove-bochs remove-limine

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

clean-llvm:
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/llvm-project/build clean

remove-llvm:
	-rm -f -r $(KASMOS_3RD_PARTY_TOOLS_DIR)/llvm-project
	-rm -f -r $(LLVM_DIR)

reinstall-llvm: remove-llvm install-llvm

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

clean-nasm:
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/nasm/build clean

remove-nasm:
	-rm -f -r $(KASMOS_3RD_PARTY_TOOLS_DIR)/nasm
	-rm -f -r $(NASM_DIR)

reinstall-nasm: remove-nasm install-nasm

# ---------------------------------------------------------------------------------------------------------------------

BOCHS_PREFIX = $(BOCHS_DIR)

BOCHS_CONFIG = --prefix=$(BOCHS_PREFIX) \
	--enable-plugins \
	--enable-show-ips \
	--enable-debugger \
    --enable-x86-debugger \
	--enable-debugger-gui \
	--enable-all-optimizations \
	--disable-docbook \
	--with-sld2 \
	--with-x11 \
	--with-wx \
	--enable-idle-hack \
	--enable-iodebug \
	--enable-a20-pin \
	--enable-x86-64 \
	--enable-smp\
	--enable-cpu-level=6 \
	--enable-long-phy-address \
    --enable-fpu \
    --enable-vmx=2 \
    --enable-svm \
    --enable-protection-keys \
    --enable-cet \
    --enable-uintr \
    --enable-memtype \
    --enable-avx \
    --enable-evex \
    --enable-amx \
    --enable-pci \
    --enable-usb \
    --enable-usb-ohci \
    --enable-usb-ehci \
    --enable-usb-xhci \
    --enable-usb-debugger \
    --enable-ne2000 \
    --enable-pnic \
    --enable-e1000 \
    --enable-clgd54xx \
    --enable-geforce \
    --enable-voodoo \
    --enable-cdrom \
    --enable-sb16 \
    --enable-es1370 \
    --enable-gameport \
    --enable-busmouse \
    --enable-xpm

install-bochs:
	mkdir -p $(KASMOS_3RD_PARTY_TOOLS_DIR)
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR) && git clone https://github.com/bochs-emu/Bochs.git )
	( cd $(KASMOS_3RD_PARTY_TOOLS_DIR)/Bochs/bochs && mkdir build-local && cd build-local && ../configure $(BOCHS_CONFIG) )
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/Bochs/bochs/build-local
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/Bochs/bochs/build-local install

clean-bochs:
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/Bochs/bochs/build-local clean

remove-bochs:
	-rm -f -r $(KASMOS_3RD_PARTY_TOOLS_DIR)/Bochs
	-rm -f -r $(BOCHS_DIR)

reinstall-bochs: remove-bochs install-bochs

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

clean-limine:
	make -C $(KASMOS_3RD_PARTY_TOOLS_DIR)/limine/build clean

remove-limine:
	-rm -f -r $(KASMOS_3RD_PARTY_TOOLS_DIR)/limine
	-rm -f -r $(LIMINE_DIR)

reinstall-limine: remove-limine install-limine
