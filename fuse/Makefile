CC ?= cc
PKG_CONFIG ?= pkg-config
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
FUSE_PKG ?= fuse
FUSE_API ?= 26
TARGET = libfactor-fuse.dylib
SHARED = -dynamiclib
else
FUSE_PKG ?= fuse3
FUSE_API ?= 31
TARGET = libfactor-fuse.so
SHARED = -shared
endif

.PHONY: all check-deps clean
all: $(TARGET)

check-deps:
	@$(PKG_CONFIG) --exists $(FUSE_PKG) || { echo "Install the $(FUSE_PKG) development package (macFUSE on macOS)."; exit 1; }

$(TARGET): bridge.c | check-deps
	$(CC) $(CPPFLAGS) $(CFLAGS) -Wall -Wextra -Werror -fPIC $(SHARED) \
		-DFUSE_USE_VERSION=$(FUSE_API) $$($(PKG_CONFIG) --cflags $(FUSE_PKG)) \
		-o $@ $< $(LDFLAGS) $$($(PKG_CONFIG) --libs $(FUSE_PKG))

clean:
	rm -f libfactor-fuse.dylib libfactor-fuse.so libfactor-fuse-test.dylib libfactor-fuse-test.so

# Factor executable (not the coreutils program with the same name).
FACTOR ?= factor
FUSE_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags $(FUSE_PKG))
TEST_TARGET = $(subst libfactor-fuse,libfactor-fuse-test,$(TARGET))

$(TEST_TARGET): checks/bridge-harness.c bridge.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -Wall -Wextra -Werror -fPIC $(SHARED) \
		-DFUSE_USE_VERSION=$(FUSE_API) $(FUSE_CFLAGS) -o $@ $<

.PHONY: test test-native test-mount
test:
	FACTOR_FUSE_ROOT="$(abspath ..)" $(FACTOR) -no-user-init checks/unit.factor

test-native: $(TEST_TARGET)
	FACTOR_FUSE_ROOT="$(abspath ..)" FACTOR_FUSE_LIBRARY="$(abspath $(TEST_TARGET))" \
		$(FACTOR) -no-user-init checks/native.factor

test-mount: all
	python3 checks/linux-mount.py "$(FACTOR)"
