# =====================================================================================================================
# === KasmOS (c)2025+ Laurent Menten (laurent.menten@gmail.com) === GNU Lesser General Public License v3.0 (LGPLv3) ===
# =====================================================================================================================

ifndef KASMOS_DIR
$(error KASMOS_DIR is not properly defined. Use 'make KASMOS_DIR=/path/to/kasmos')
endif

include $(KASMOS_DIR)/Makefile.rules

# =====================================================================================================================
# =
# =====================================================================================================================

CONCURRENCY_LIB_FILE = $(KASMOS_LIB_DIR)/libconcurrency.a

all: $(CONCURRENCY_LIB_FILE)

$(CONCURRENCY_LIB_FILE): $(OBJS)
	$(AR) rcs $(CONCURRENCY_LIB_FILE) $^

# dependencies
-include $(DEPS)

# =====================================================================================================================
#
# =====================================================================================================================

clean:
	-rm -r $(OBJ_DIR)
	-rm $(CONCURRENCY_LIB_FILE)
