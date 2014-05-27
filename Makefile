# Copyright (c) 2013 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# GNU Makefile based on shared rules provided by the Native Client SDK.
# See README.Makefiles for more details.

VALID_TOOLCHAINS := pnacl emscripten newlib

ifneq (,$(PEPPERJS_SRC_ROOT))
  include $(PEPPERJS_SRC_ROOT)/tools/common.mk
else
  ifneq (,$(NACL_SDK_ROOT))
    include $(NACL_SDK_ROOT)/tools/common.mk
  else
    $(error NACL_SDK_ROOT is not set. It should be an absolute path)
  endif
endif

TARGET = NaClAMBullet
LIBS = BulletDynamics BulletCollision LinearMath ppapi pthread

ifeq (emscripten,$(TOOLCHAIN))
EMSCRIPTEN_USR = $(PEPPERJS_SRC_ROOT)/emscripten/usr
CFLAGS += -I$(EMSCRIPTEN_USR)/include/bullet
LDFLAGS = -L$(EMSCRIPTEN_USR)/lib
endif

ifeq (pnacl,$(TOOLCHAIN))
PNACL_USR = $(PNACL_BIN)/../usr
CFLAGS += -I$(PNACL_USR)/include/bullet
LDFLAGS = -L$(PNACL_USR)/lib
endif

CFLAGS += -I$(CURDIR)
CFLAGS += -Wall -Wno-overloaded-virtual -Wno-unused-variable
SOURCES = \
	NaClAMBase/NaClAMBase.cpp \
	NaClAMBase/NaClAMMessageCollector.cpp \
	NaClAMBase/jsoncpp.cpp \
	NaClAMBullet/NaClAMBullet.cpp

.PHONY: ports
ports:
ifeq (newlib,$(TOOLCHAIN))
	$(MAKE) -C third_party/naclports bullet NACL_ARCH=i686
	$(MAKE) -C third_party/naclports bullet NACL_ARCH=x86_64
	$(MAKE) -C third_party/naclports bullet NACL_ARCH=arm
endif
ifeq (pnacl,$(TOOLCHAIN))
	$(MAKE) -C third_party/naclports bullet NACL_ARCH=pnacl
endif
ifeq (emscripten,$(TOOLCHAIN))
	$(MAKE) -C third_party/naclports bullet NACL_ARCH=emscripten
endif

# Build rules generated by macros from common.mk:

$(foreach src,$(SOURCES),$(eval $(call COMPILE_RULE,$(src),$(CFLAGS))))

ifeq ($(CONFIG),Release)
$(eval $(call LINK_RULE,$(TARGET)_unstripped,$(SOURCES),$(LIBS),$(DEPS),$(LDFLAGS)))
$(eval $(call STRIP_RULE,$(TARGET),$(TARGET)_unstripped))
else
$(eval $(call LINK_RULE,$(TARGET),$(SOURCES),$(LIBS),$(DEPS),$(LDFLAGS)))
endif

$(eval $(call NMF_RULE,$(TARGET),))
