# Makefile for Silk SDK

# Platform detection and settings

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

COMPILE.c.cmdline   = $(CC) -c $(CFLAGS) $(ADDED_CFLAGS) -o $@ $<
COMPILE.S.cmdline   = $(CC) -c $(CFLAGS) $(ADDED_CFLAGS) -o $@ $<
COMPILE.cpp.cmdline = $(CXX) -c $(CFLAGS) $(ADDED_CFLAGS) -o $@ $<
LINK.o              = $(CXX) $(LDPREFLAGS) $(LDFLAGS)
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

clean:
	$(RM) $(TARGET)* $(OBJS)