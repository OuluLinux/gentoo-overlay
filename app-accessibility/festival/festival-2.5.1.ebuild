# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools toolchain-funcs flag-o-matic

DESCRIPTION="Festival speech synthesis system"
HOMEPAGE="https://festvox.org/festival/"

FESTIVAL_COMMIT="5db6ee949f4e4e9da25c87bd03b90e69f9011393"
SPEECH_TOOLS_COMMIT="63ff01938f81443f5a294bc5f9ea6ac6ab38f6b0"

SRC_URI="
	https://codeload.github.com/festvox/festival/tar.gz/${FESTIVAL_COMMIT} -> festival-${PV}.tar.gz
	https://codeload.github.com/festvox/speech_tools/tar.gz/${SPEECH_TOOLS_COMMIT} -> speech_tools-${PV}.tar.gz
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

src_unpack() {
	default

	local name commit src_dir dst_dir

	for name in festival speech_tools; do
		case "${name}" in
			festival) commit="${FESTIVAL_COMMIT}" ;;
			speech_tools) commit="${SPEECH_TOOLS_COMMIT}" ;;
		esac

		src_dir="${WORKDIR}/${name}-${commit}"
		dst_dir="${WORKDIR}/${name}"

		if [ -d "${dst_dir}" ]; then
			rm -rf "${dst_dir}"
		fi

		if [ -d "${src_dir}" ]; then
			mv "${src_dir}" "${dst_dir}"
		else
			die "Missing ${src_dir}"
		fi
	done
}

src_prepare() {
	default

	local speech_tools_src="${WORKDIR}/speech_tools"
	local inst_tmpl_dir="${speech_tools_src}/base_class/inst_tmpl"
	local force_file="${inst_tmpl_dir}/force_instantiations.cc"

	if [ ! -f "${force_file}" ]; then
		cat <<'EOF' > "${force_file}"
#include "EST_String.h"
#include "EST_Val.h"
#include "EST_TVector.h"
#include "EST_TSimpleVector.h"
#include "EST_TMatrix.h"
#include "EST_TSimpleMatrix.h"
#include "EST_TList.h"

template class EST_TItem<EST_String>;
template class EST_TList<EST_String>;

template class EST_TVector<EST_String>;
template class EST_TVector<char>;
template class EST_TVector<float>;

template class EST_TSimpleVector<char>;
template class EST_TSimpleVector<float>;

template class EST_TMatrix<EST_Val>;
template class EST_TSimpleMatrix<float>;
template class EST_TSimpleMatrix<char>;
EOF
	fi

	local inst_makefile="${inst_tmpl_dir}/Makefile"

	if ! grep -q "force_instantiations.cc" "${inst_makefile}"; then
		python3 - "${inst_makefile}" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()
needle = "vector_dvector_t.cc vector_dmatrix_t.cc \\\n\t\\\n"
replacement = "vector_dvector_t.cc vector_dmatrix_t.cc \\\n\tforce_instantiations.cc \\\n\t\\\n"
if needle not in text:
    raise SystemExit("template block not found")
text = text.replace(needle, replacement, 1)
path.write_text(text)
PY
	fi

	(
		cd "${speech_tools_src}" || die
		patch -p1 < "${FILESDIR}/editline-tgetstr.patch"
	)

	if [ ! -f "${speech_tools_src}/config/config" ]; then
		(
			cd "${speech_tools_src}" || die
			./configure --prefix=/usr
		)
		perl -0pi -e 's/TERMCAPLIB = -lcurses/TERMCAPLIB = -lncurses -ltinfo/' \
			"${speech_tools_src}/config/config"
	fi
}

SCRIPTS="saytime text2pos latest scfg_parse_text text2wave make_utts dumpfeats durmeanstd powmeanstd run-festival-script text2utt"
SERVER_SCRIPTS="festival_server festival_server_control"

src_configure() {
	econf "--prefix=/usr"
}

src_compile() {
	append-cflags -std=gnu89
	append-cxxflags -std=gnu++03
	(
		cd "${WORKDIR}/speech_tools" || die
		emake
	)
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

	# Remove the nested QA-triggering directory created by install_symlink_html_docs.
	rm -rf "${ED}/var/tmp/portage/app-accessibility/festival-2.5.1/image"
}
