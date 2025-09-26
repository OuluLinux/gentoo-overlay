# Copyright 2025 OuluLinux
# Distributed under the terms of the GNU General Public License v3

DESCRIPTION="Ultimate++ Framework"
HOMEPAGE="http://www.ultimatepp.org/"
SRC_URI="https://www.ultimatepp.org/downloads/upp-posix-${PV}.tar.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64"
RDEPEND="sys-devel/gcc
	 dev-libs/glib
	 x11-libs/gtk+
	 media-libs/freetype
	 x11-libs/cairo
	 dev-libs/atk
	 x11-libs/pango"

DEPEND="${RDEPEND}"

S=${WORKDIR}/upp

src_unpack() {
	unpack ${A}
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
