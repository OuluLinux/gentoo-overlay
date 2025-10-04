# Copyright 2025 OuluLinux
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit git-r3

DESCRIPTION="Ultimate++ Framework"
HOMEPAGE="https://www.ultimatepp.org/"
# Live ebuild: clone suoraan upstream-reposta
EGIT_REPO_URI="https://github.com/ultimatepp/ultimatepp.git"
EGIT_BRANCH="master"

LICENSE="BSD"
SLOT="0"
# Live: ei KEYWORDS-riviä
PROPERTIES="live"
RESTRICT="mirror"

RDEPEND="sys-devel/gcc
	 dev-libs/glib
	 x11-libs/gtk+
	 media-libs/freetype
	 x11-libs/cairo
	 dev-libs/atk
	 x11-libs/pango"

DEPEND="${RDEPEND}"
# git-r3 hoitaa BDEPEND=dev-vcs/git

# git-r3 check outtaa oletuksena ${WORKDIR}/${P}
S=${WORKDIR}/${P}

src_prepare() {
	default  # eapply_user jne.
	# Upstreamin makefilet saattavat peittää CFLAGS/CXXFLAGS – jätetään koukku tarvittaessa:
	# sed -i -e 's/^CC = .*//; s/^CFLAGS = .*//; s/^CPPFLAGS = .*//' uppsrc/Makefile || die
}

src_compile() {
	cd "${S}" || die
	emake || die "emake failed"
}

src_install() {
	local share_root=/usr/share/${PN}

	einfo "Installing TheIDE (safe to ignore following QA warnings)"

	if [[ -x ${S}/theide ]]; then
		dobin "${S}/theide" || die "failed to install theide"
	else
		die "theide binary not found"
	fi

	if [[ -x ${S}/umk ]]; then
		dobin "${S}/umk" || die "failed to install umk"
	fi

	insinto "${share_root}"

	local sharedirs=(examples reference tutorial uppsrc)
	local dir
	for dir in "${sharedirs[@]}"; do
		if [[ -d ${S}/${dir} ]]; then
			doins -r "${S}/${dir}" || die "failed to install ${dir}"
		fi
	done

	local sharefiles=(configure configure_makefile license.chk README)
	local file
	for file in "${sharefiles[@]}"; do
		if [[ -e ${S}/${file} ]]; then
			doins "${S}/${file}" || die "failed to install ${file}"
		fi
	done

	if [[ -d ${S}/umks32 ]]; then
		doins -r "${S}/umks32" || die "failed to install umks32"
	fi

	# dictionary files
	insinto "${share_root}/dictionaries"
	local dict
	for dict in "${S}"/*.udc; do
		[[ -e ${dict} ]] || continue
		doins "${dict}" || die "failed to install dictionary ${dict}"
	done

	elog "When you run 'theide' the first time as a user, it will ask to copy the upp shares"
	elog "to your homedirectory. This is the normal procedure, the shared files will never"
	elog "be used directly."
}

