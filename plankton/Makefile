TARGET = plankton
VERSION = 0.1
CC = xcrun -sdk iphoneos clang -arch armv7 -arch arm64 -miphoneos-version-min=9.0
LDID = ldid
GO_EASY_ON_ME=1
.PHONY: all clean

all: clean postinst
	sh make-plankton.sh
	mkdir org.brandonplank.plankton_$(VERSION)_iphoneos-arm
	mkdir org.brandonplank.plankton_$(VERSION)_iphoneos-arm/DEBIAN
	mkdir org.brandonplank.plankton_$(VERSION)_iphoneos-arm/Library
	mkdir org.brandonplank.plankton_$(VERSION)_iphoneos-arm/Library/Frameworks
	cp -r libplankton.framework org.brandonplank.plankton_$(VERSION)_iphoneos-arm/Library/Frameworks
	cp control org.brandonplank.plankton_$(VERSION)_iphoneos-arm/DEBIAN
	mv postinst org.brandonplank.plankton_$(VERSION)_iphoneos-arm/DEBIAN
	mkdir org.brandonplank.plankton_$(VERSION)_iphoneos-arm/usr
	mkdir org.brandonplank.plankton_$(VERSION)_iphoneos-arm/usr/bin
	mv Build/Debug-iphoneos/plankton org.brandonplank.plankton_$(VERSION)_iphoneos-arm/usr/bin
	$(LDID) -Sentitlements.xml org.brandonplank.plankton_$(VERSION)_iphoneos-arm/usr/bin/plankton
	dpkg -b org.brandonplank.plankton_$(VERSION)_iphoneos-arm

postinst: clean
	$(CC) postinst.c -o postinst
	strip postinst
	$(LDID) -Sentitlements.xml postinst

clean:
	rm -rf org.brandonplank.plankton_* postinst plankton/.theos
