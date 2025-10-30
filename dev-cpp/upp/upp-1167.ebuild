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

src_prepare() {
	default
	# Fix Makefile to respect system CFLAGS/CXXFLAGS
	sed -i \
		-e "s:CFLAGS = -O3 -ffunction-sections -fdata-sections :CFLAGS += ${CFLAGS}:" \
		-e "s:CXXFLAGS = -O3 -ffunction-sections -fdata-sections  -std=c++17:CXXFLAGS += ${CXXFLAGS} -std=c++17:" \
		"${S}/Makefile" || die "Failed to modify Makefile"
}

src_unpack() {
	unpack ${A}
	cd ${S}
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
