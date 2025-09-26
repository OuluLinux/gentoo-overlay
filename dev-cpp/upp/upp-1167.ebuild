# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Ultimate++ Framework"
HOMEPAGE="http://www.ultimatepp.org/"
SRC_URI="http://upp-mirror.googlecode.com/files/upp-x11-src-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
RDEPEND="sys-devel/gcc
	 dev-libs/glib
	 x11-libs/gtk+
	 media-libs/freetype
	 x11-libs/cairo
	 dev-libs/atk
	 x11-libs/pango"

DEPEND="${RDEPEND}"

S=${WORKDIR}/upp-x11-src-${PV}

src_unpack() {
	unpack ${A}
	cd ${S}
	einfo "TODO: Custom CFLAGS do not work"
#	echo "CFLAGS = gcc ${CFLAGS}" > uppsrc/Makefile.new
#	echo "CPPFLAGS = g++ ${CXXFLAGS}" >> uppsrc/Makefile.new
#	cat uppsrc/Makefile | sed -e "s/^CC = .*//" \
#	    | sed -e "s/^CFLAGS = .*//" | sed -e "s/^CPPFLAGS = .*//" \
#	    >> uppsrc/Makefile.new
#	rm uppsrc/Makefile
#	mv uppsrc/Makefile.new uppsrc/Makefile
}

src_compile() {
	emake || die "make failed"
}

src_install () {
	einfo "Installing TheIDE (safe to ignore following QA warnings)"
	mv ${S}/uppsrc/ide.out ${S}/theide
	dobin theide

	mkdir -p ${D}/usr/share/upp
	cp ${S}/GCC.bm ${D}/usr/share/upp
	cp -r ${S}/bazaar ${D}/usr/share/upp
	cp -r ${S}/examples ${D}/usr/share/upp
	cp -r ${S}/reference ${D}/usr/share/upp
	cp -r ${S}/tutorial ${D}/usr/share/upp
	cp -r ${S}/uppsrc ${D}/usr/share/upp
	rm -rf ${D}/usr/share/upp/uppsrc/_out

	elog "When you run 'theide' the first time as a user, it will ask to copy the upp shares"
	elog "to your homedirectory. This is the normal procedure, the shared files will never"
	elog "be used directly."
}
