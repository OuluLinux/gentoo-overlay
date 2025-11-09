EAPI=8

COMMON_PV="1.0g-20051204-5"
MV_PV="20041119-3"

DESCRIPTION="SuoPuhe Finnish Festival voices (common dataset + male voice)"
HOMEPAGE="https://phon.joensuu.fi/suopuhe/"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="app-accessibility/festival"
RDEPEND="${DEPEND}"

SRC_URI=(
	"https://mirrors.edge.kernel.org/ubuntu/pool/universe/f/festvox-suopuhe-lj/festvox-suopuhe-common_${COMMON_PV}_all.deb -> festvox-suopuhe-common_${COMMON_PV}_all.deb"
	"https://mirrors.edge.kernel.org/ubuntu/pool/universe/f/festvox-suopuhe-mv/festvox-suopuhe-mv_${MV_PV}_all.deb -> festvox-suopuhe-mv_${MV_PV}_all.deb"
)

S="${WORKDIR}"

src_unpack() {
	cd "${WORKDIR}" || die

	local _dist_dir="${DISTDIR}/${DIST_SUBDIR}"
	local _local_override="/home/sblo/distfiles/27"

	for _deb in festvox-suopuhe-common_${COMMON_PV}_all.deb \
		festvox-suopuhe-mv_${MV_PV}_all.deb; do
		local _source="${_dist_dir}/${_deb}"
		if [ -r "${_local_override}/${_deb}" ]; then
			_source="${_local_override}/${_deb}"
		fi

		cp "${_source}" "${_deb}" || die "cannot copy ${_deb}"
		ar x "${_deb}" || die "cannot unpack ${_deb}"
		for _archive in data.tar.*; do
			tar -xf "${_archive}" || die "failed to extract ${_archive}"
		done
		rm -f "${_deb}" debian-binary control.tar.* data.tar.*
	done
}

src_install() {
	dodir /usr/share/festival
	cp -a "${WORKDIR}/usr/share/festival/voices" "${D}/usr/share/festival/"

	dodir /usr/share/doc/festvox-suopuhe-common
	dodir /usr/share/doc/festvox-suopuhe-mv
	cp -a "${WORKDIR}/usr/share/doc/festvox-suopuhe-common/." "${D}/usr/share/doc/festvox-suopuhe-common/"
	cp -a "${WORKDIR}/usr/share/doc/festvox-suopuhe-mv/." "${D}/usr/share/doc/festvox-suopuhe-mv/"

	local _files_dir="${FILESDIR:-/home/sblo/gentoo-overlay/app-accessibility/festvox-suopuhe/files}"

	dodir /usr/bin
	for _exe in sano sano-tiedostoon; do
		cp "${_files_dir}/${_exe}" "${D}/usr/bin/${_exe}"
		chmod 0755 "${D}/usr/bin/${_exe}"
	done

	cp "${_files_dir}/festival.scm" "${D}/usr/share/doc/festvox-suopuhe-common/festival.scm"
}
