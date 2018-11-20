#
# snmpb project top-level makefile. Supports Linux, MacOSX, NetBSD & Cygwin/Windows
#
#    Copyright (C) 2004-2017 Martin Jolicoeur (snmpb1@gmail.com) 
#
#    This file is part of the SnmpB project 
#    (http://sourceforge.net/projects/snmpb)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
os:=$(shell uname -s)

# Default QT for windows: static 64 bits QT under MSYS2
WINQT_PREFIX=/mingw64/qt5-static/bin/

ifneq ($(findstring BSD,${os}),)
INSTALL=install
SHARE=share
else
INSTALL=install -v
SHARE=share/apps
endif

ifndef INSTALL_PREFIX
INSTALL_PREFIX=/usr/local
endif

ifneq ($(findstring MINGW,${os}),)
LIBSMI=libsmi/win/libsmi.a
else
LIBSMI=libsmi/lib/.libs/libsmi.a
endif

all:app/makefile.snmpb \
	libtomcrypt/libtomcrypt.a \
	qwt/lib/libqwt.a \
	$(LIBSMI)
	$(MAKE) -C app

libtomcrypt/libtomcrypt.a:
	$(MAKE) -C libtomcrypt 

ifneq ($(findstring MINGW,${os}),)
$(LIBSMI):
	$(MAKE) -C libsmi/win -f Makefile.mingw libs
else
$(LIBSMI): libsmi/Makefile
	$(MAKE) -C libsmi
endif

libsmi/Makefile:
ifneq ($(findstring Darwin,${os}),)
	# MacOSX
	cd libsmi; ./configure --disable-shared --disable-yang --with-pathseparator=';' --with-dirseparator='/' --with-smipath='/Applications/SnmpB.app/Contents/MacOS/mibs;/Applications/SnmpB.app/Contents/MacOS/pibs'
else
	# Linux/BSD
	cd libsmi; ./configure --disable-shared --disable-yang --with-pathseparator=';' --with-dirseparator='/' --with-smipath=${INSTALL_PREFIX}'/${SHARE}/snmpb/mibs;'${INSTALL_PREFIX}'/${SHARE}/snmpb/pibs'
endif

qwt/lib/libqwt.a: qwt/Makefile
	$(MAKE) -C qwt

qwt/Makefile:
ifneq ($(findstring MINGW,${os}),)
	cd qwt; ${WINQT_PREFIX}qmake  qwt.pro
else
ifneq ($(findstring Darwin,${os}),)
	# MacOSX
	cd qwt; qmake qwt.pro
else
	# Linux/BSD
	cd qwt; qmake qwt.pro
endif
endif

app/makefile.snmpb:
ifneq ($(findstring MINGW,${os}),)
	cd app; ${WINQT_PREFIX}qmake -o makefile.snmpb snmpb.pro
else
ifneq ($(findstring Darwin,${os}),)
    # MacOSX
	cd app; qmake -o makefile.snmpb snmpb.pro
else
	# Linux/BSD
	cd app; qmake -o makefile.snmpb snmpb.pro
endif
endif

clean:
	-$(MAKE) -C libtomcrypt clean
ifneq ($(findstring MINGW,${os}),)
	-$(MAKE) -C libsmi/win -f Makefile.mingw clean
else
	-$(MAKE) -C libsmi clean
	rm libsmi/Makefile
endif
	-$(MAKE) -C qwt clean
	-$(MAKE) -C app clean

install:
	$(INSTALL) -d ${INSTALL_PREFIX}/bin ${INSTALL_PREFIX}/${SHARE}/snmpb/mibs ${INSTALL_PREFIX}/${SHARE}/snmpb/pibs
	$(INSTALL) -m 4755 -D -s -o root app/snmpb ${INSTALL_PREFIX}/bin
	$(INSTALL) -m 444 -o root libsmi/mibs/iana/* ${INSTALL_PREFIX}/${SHARE}/snmpb/mibs
	$(INSTALL) -m 444 -o root libsmi/mibs/ietf/* ${INSTALL_PREFIX}/${SHARE}/snmpb/mibs
	$(INSTALL) -m 444 -o root libsmi/mibs/tubs/* ${INSTALL_PREFIX}/${SHARE}/snmpb/mibs
	$(INSTALL) -m 444 -o root libsmi/pibs/ietf/* ${INSTALL_PREFIX}/${SHARE}/snmpb/pibs
	$(INSTALL) -m 444 -o root libsmi/pibs/tubs/* ${INSTALL_PREFIX}/${SHARE}/snmpb/pibs
	rm -f ${INSTALL_PREFIX}/${SHARE}/snmpb/mibs/Makefile* ${INSTALL_PREFIX}/${SHARE}/snmpb/pibs/Makefile*
	$(INSTALL) -d ${INSTALL_PREFIX}/share/applications ${INSTALL_PREFIX}/share/mime/packages
	$(INSTALL) -m 444 -o root app/snmpb.desktop ${INSTALL_PREFIX}/share/applications
	$(INSTALL) -m 444 -o root app/snmpb.xml ${INSTALL_PREFIX}/share/mime/packages
	$(INSTALL) -d ${INSTALL_PREFIX}/share/icons/hicolor/128x128/apps ${INSTALL_PREFIX}/share/pixmaps ${INSTALL_PREFIX}/share/icons/hicolor/scalable/apps
	$(INSTALL) -m 444 -o root app/images/snmpb.png ${INSTALL_PREFIX}/share/icons/hicolor/128x128/apps
	$(INSTALL) -m 444 -o root app/images/snmpb.png ${INSTALL_PREFIX}/share/pixmaps
	$(INSTALL) -m 444 -o root app/images/snmpb.svg ${INSTALL_PREFIX}/share/icons/hicolor/scalable/apps

