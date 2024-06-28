#
# Makefile for Silk SDK
#
# Copyright (c) 2012, Skype Limited
# All rights reserved.
#

#Platform detection and settings

EXESUFFIX =
LIBPREFIX = lib
LIBSUFFIX = .a
OBJSUFFIX = .o

CC     = gcc
CXX    = g++
AR     = ar
RANLIB = ranlib

cppflags-from-defines 	= $(addprefix -D,$(1))
cppflags-from-includes 	= $(addprefix -I,$(1))
ldflags-from-ldlibdirs 	= $(addprefix -L,$(1))
ldlibs-from-libs        = $(addprefix -l,$(1))

CFLAGS	+= -Wall -O3
CFLAGS  += $(call cppflags-from-defines,$(CDEFINES))
CFLAGS  += $(call cppflags-from-defines,$(ADDED_DEFINES))
CFLAGS  += $(call cppflags-from-includes,$(CINCLUDES))
LDFLAGS += $(call ldflags-from-ldlibdirs,$(LDLIBDIRS))
LDLIBS  += $(call ldlibs-from-libs,$(LIBS))

COMPILE.c.cmdline   = $(CC) -c $(ARCH_FLAGS) $(CFLAGS) $(ADDED_CFLAGS) -o $@ $<
COMPILE.S.cmdline   = $(CC) -c $(ARCH_FLAGS) $(CFLAGS) $(ADDED_CFLAGS) -o $@ $<
COMPILE.cpp.cmdline = $(CXX) -c $(ARCH_FLAGS) $(CFLAGS) $(ADDED_CFLAGS) -o $@ $<
LINK.o              = $(CXX) $(ARCH_FLAGS) $(LDPREFLAGS) $(LDFLAGS)
LINK.o.cmdline      = $(LINK.o) $^ $(LDLIBS) -o $@$(EXESUFFIX)
ARCHIVE.cmdline     = $(AR) $(ARFLAGS) $@ $^ && $(RANLIB) $@

%$(OBJSUFFIX):%.c
	$(COMPILE.c.cmdline)

%$(OBJSUFFIX):%.cpp
	$(COMPILE.cpp.cmdline)

%$(OBJSUFFIX):%.S
	$(COMPILE.S.cmdline)

# Directives

CINCLUDES += interface src test

# VPATH e.g. VPATH = src:../headers
VPATH = ./ \
        interface \
        src \
		test

# Variable definitions
LIB_NAME = SKP_SILK_SDK
TARGET = $(LIBPREFIX)$(LIB_NAME)$(LIBSUFFIX)

SRCS_C = $(wildcard src/*.c)
OBJS := $(patsubst %.c,%$(OBJSUFFIX),$(SRCS_C))

LIBS = \
	$(LIB_NAME)

LDLIBDIRS = ./

# Rules
default: all

all: $(TARGET)

lib: $(TARGET)

$(TARGET): $(OBJS)
	$(ARCHIVE.cmdline)

# Universal binary targets for MacOS
universal: clean $(TARGET).arm64 $(TARGET).x86_64
	lipo -create -output $(TARGET) $(TARGET).arm64 $(TARGET).x86_64

$(TARGET).arm64:
	$(MAKE) ARCH_FLAGS="-arch arm64" all
	mv $(TARGET) $(TARGET).arm64
	$(RM) $(OBJS) 

$(TARGET).x86_64:
	$(MAKE) ARCH_FLAGS="-arch x86_64" all
	mv $(TARGET) $(TARGET).x86_64
	$(RM) $(OBJS) 

clean:
	$(RM) $(TARGET)* $(OBJS)

