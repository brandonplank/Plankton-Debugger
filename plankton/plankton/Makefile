export TARGET=iphone:clang::9.0
export ARCHS=armv7 arm64 arm64e
export DEBUG=0
GO_EASY_ON_ME=1
include /Users/brandonplank/theos/makefiles/common.mk

TOOL_NAME = plankton

$(TOOL_NAME)_FILES = you2.m
$(TOOL_NAME)_CFLAGS = -fobjc-arc
$(TOOL_NAME)_CODESIGN_FLAGS = -S../entitlements.xml

include $(THEOS_MAKE_PATH)/tool.mk
