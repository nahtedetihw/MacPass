export ARCHS = arm64 arm64e
export TARGET := iphone:clang:latest:13.0

DEBUG = 0
FINALPACKAGE = 1

PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

SYSROOT=$(THEOS)/sdks/iphoneos14.0.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MacPass
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_LIBRARIES = gcuniversal
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei

SUBPROJECTS += macpassprefs

after-install::
	install.exec "sbreload"

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk