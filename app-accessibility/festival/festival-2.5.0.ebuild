# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools toolchain-funcs flag-o-matic

DESCRIPTION="Festival speech synthesis system"
HOMEPAGE="https://festvox.org/festival/"
SRC_URI="
	http://www.festvox.org/packed/festival/2.5/festival-2.5.0-release.tar.gz
	http://www.festvox.org/packed/festival/2.5/speech_tools-2.5.0-release.tar.gz
"
S="${WORKDIR}/festival"

LICENSE="X11"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	media-libs/alsa-lib
	sys-libs/ncurses
	app-accessibility/speech-tools
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

SCRIPTS="saytime text2pos latest scfg_parse_text text2wave make_utts dumpfeats durmeanstd powmeanstd run-festival-script text2utt"
SERVER_SCRIPTS="festival_server festival_server_control"

src_configure() {
	econf "--prefix=/usr"
}

src_compile() {
	append-cflags -std=gnu89
	append-cxxflags -std=gnu++03
	emake
}

src_install() {
	local festival_home="/usr/share/festival"
	local speech_tools_dest="/usr/$(get_libdir)/speech-tools"

	dodir "${ED}${festival_home}"
	insinto "${festival_home}"
	doins -r lib

	insinto "${festival_home}/examples"
	doins -r examples

	docinto "/usr/share/doc/festival"
	doins -r doc

	for script in ${SCRIPTS}; do
		local src_file="${S}/examples/${script}.sh"
		local dst_file="${ED}/usr/bin/${script}"
		mkdir -p "$(dirname ${dst_file})"
		{
			echo '#!/bin/sh'
			printf '"true" ; exec "/usr/bin/festival" --script '\''$0 $*'\''\n'
			cat "${src_file}"
		} > "${dst_file}"
		chmod 0755 "${dst_file}"
		sed -i -e "s:${S}:${festival_home}:g" \
			-e "s:${WORKDIR}/speech_tools:${speech_tools_dest}:g" \
			-e "s:${S}/bin/festival:/usr/bin/festival:g" \
		"${dst_file}"
	done

	dobin src/main/festival src/main/festival_client

	for script in ${SERVER_SCRIPTS}; do
		local src_file="${S}/bin/${script}"
		local dst_file="${ED}/usr/bin/${script}"
		dobin "${src_file}"
		sed -i -e "s:${S}:${festival_home}:g" \
			-e "s:${WORKDIR}/speech_tools:${speech_tools_dest}:g" \
			-e "s:/tmp/festival/festival:${festival_home}:g" \
			-e "s:/tmp/festival/speech_tools:${speech_tools_dest}:g" \
		"${dst_file}"
	done
}
