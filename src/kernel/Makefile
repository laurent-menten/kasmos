# =====================================================================================================================
# === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
# =====================================================================================================================

ifndef KASMOS_DIR
$(error KASMOS_DIR is not properly defined. Use 'make KASMOS_DIR=/path/to/kasmos')
endif

include $(KASMOS_DIR)/Makefile.rules

# =====================================================================================================================
#
# =====================================================================================================================

all: $(KERNEL_FILE)

# =====================================================================================================================
#
# =====================================================================================================================

KERNEL_DATA_BUFFER_SIZE = 512K

KERNEL_TMP_FILE = $(KASMOS_BUILD_DIR)/kernel.tmp.elf

LIBS = -llists -lstrings

$(KERNEL_FILE): $(OBJS)
	$(LLVM_LD_EXE) \
		-defsym KERNEL_DATA_BUFFER_SIZE=$(KERNEL_DATA_BUFFER_SIZE) \
		-L$(KASMOS_LIB_DIR) $^ $(LIBS) \
	  	-Map=$(KERNEL_MAP_FILE) --cref -o $(KERNEL_TMP_FILE) -T kernel.lds
	$(LLVM_OBJDUMP_EXE) -d -l -h -S -C -M intel -C $(KERNEL_TMP_FILE) > $(KERNEL_LST_FILE)
	$(LLVM_NM_EXE) -n -C $(KERNEL_TMP_FILE) | grep -i ' [TtRrDdBb] ' | awk '{print $$1, $$3}' > $(KERNEL_SYMB_FILE)
	$(LLVM_OBJCOPY_EXE) --only-keep-debug $(KERNEL_TMP_FILE) $(KERNEL_DBG_FILE)
	$(LLVM_STRIP_EXE) --strip-debug --strip-unneeded -o $(KERNEL_FILE) $(KERNEL_TMP_FILE)
	$(LLVM_OBJCOPY_EXE) --add-gnu-debuglink=$(KERNEL_DBG_FILE) $(KERNEL_FILE)
	rm $(KERNEL_TMP_FILE)

# dependencies
-include $(DEPS)

# =====================================================================================================================
#
# =====================================================================================================================

clean:
	-rm -r $(OBJ_DIR)
	-rm $(KERNEL_FILE) $(KERNEL_DBG_FILE) $(KERNEL_LST_FILE) $(KERNEL_MAP_FILE) $(KERNEL_SYMB_FILE)
