# Copyright 2025 OuluLinux
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit desktop flag-o-matic toolchain-funcs wrapper xdg

DESCRIPTION="Tesseract-Sauerbraten is a FOSS game engine (Cube 2 + Tesseract) with freeware game data (Sauerbraten)"
HOMEPAGE="http://sauerbraten.org/"
SRC_URI="https://github.com/OuluLinux/Tesseract-Sauerbraten/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Tesseract-Sauerbraten-${PV}"

LICENSE="ZLIB freedist"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug dedicated server"

DEPEND="
	>=net-libs/enet-1.3.6:1.3
	sys-libs/zlib
	!dedicated? (
		media-libs/libsdl2[X,opengl]
		media-libs/sdl2-image
		media-libs/sdl2-mixer
		virtual/opengl
		virtual/glu
		x11-libs/libX11
	)
"
RDEPEND="
	${DEPEND}
	acct-group/sauerbraten
	dedicated? ( acct-user/sauerbraten )
"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	# Respect user toolchain flags, use system enet, modern freetype detection
	"${FILESDIR}"/tesseract-sauerbraten-2025.9-build.patch

	# More sensible SDL include handling
	"${FILESDIR}"/tesseract-sauerbraten-2020.12.29-includefix.patch
)

src_prepare() {
	rm -rf tess_client tess_server src/{include,lib,vcpp} || die

	default

	if [[ -f README.html ]]; then
		sed -i -e 's:docs/::' README.html || die
	fi
}

src_compile() {
	tc-export CXX PKG_CONFIG

	use debug && append-cppflags -D_DEBUG

	emake -C src \
		master \
		$(usex dedicated "server" "$(usex server "server client" "client")")
}

src_install() {
	local libexecdir="/usr/lib"
	local datadir="/usr/share/${PN}"
	local statedir="/var/lib/${PN}"

	if ! use dedicated ; then
		insinto "${datadir}"
		doins -r config packages

		exeinto "${libexecdir}"
		doexe src/tess_client

		make_wrapper "${PN}-client" "${libexecdir}/tess_client -q\$HOME/.${PN} -r" "${datadir}"

		newicon -s 256 data/cube.png ${PN}.png
		make_desktop_entry "${PN}-client" "Cube 2: Tesseract-Sauerbraten"
	fi

	insinto "${statedir}"
	if [[ -f config/server-init.cfg ]]; then
		doins config/server-init.cfg
	fi

	exeinto "${libexecdir}"
	doexe src/tess_master

	if use dedicated || use server ; then
		doexe src/tess_server
	fi

	make_wrapper "${PN}-server" "${libexecdir}/tess_server -k${datadir} -q${statedir}"
	make_wrapper "${PN}-master" "${libexecdir}/tess_master ${statedir}"

	cp "${FILESDIR}"/tesseract-sauerbraten.init "${T}/${PN}.init" || die
	sed -i \
		-e "s:%SYSCONFDIR%:${statedir}:g" \
		-e "s:%LIBEXECDIR%:${libexecdir}:g" \
		-e "s:%/var/lib/%:/var/run:g" \
		"${T}/${PN}.init" || die
	newinitd "${T}/${PN}.init" ${PN}

	cp "${FILESDIR}"/tesseract-sauerbraten.conf "${T}/${PN}.conf" || die
	sed -i \
		-e "s:%SYSCONFDIR%:${statedir}:g" \
		-e "s:%LIBEXECDIR%:${libexecdir}:g" \
		-e "s:%GAMES_USER_DED%:sauerbraten:g" \
		-e "s:%GAMES_GROUP%:sauerbraten:g" \
		"${T}/${PN}.conf" || die
	newconfd "${T}/${PN}.conf" ${PN}

	local doc_files=()

	if [[ -f README.md ]]; then
		doc_files+=(README.md)
	fi

	if compgen -G 'src/readme_*.txt' > /dev/null ; then
		doc_files+=(src/readme_*.txt)
	fi

	if [[ -f README.html ]]; then
		doc_files+=(README.html)
	fi

	if [[ ${#doc_files[@]} -gt 0 ]]; then
		dodoc "${doc_files[@]}"
	fi

	if [[ -d docs ]]; then
		docinto html
		dodoc -r docs/*
	fi
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "If you plan to use map editor feature copy all map data from /usr/share/${PN}"
	elog "to corresponding folder in your HOME/.${PN}"
}
