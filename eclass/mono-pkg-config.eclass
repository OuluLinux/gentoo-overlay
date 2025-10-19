# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mono-pkg-config.eclass
# @MAINTAINER:
# .NET Project <dotnet@gentoo.org>
# @AUTHOR:
# Original author unknown
# @SUPPORTED_EAPIS: 7 8
# @BLURB: Eclass for Mono-based pkg-config operations
# @DESCRIPTION:
# This eclass provides functions for creating pkg-config files for Mono-related packages.

case ${EAPI:-0} in
	7|8) ;;
	*) die "${ECLASS}: EAPI ${EAPI} not supported" ;;
esac

# @FUNCTION: einstall_pc_file
# @USAGE: <assembly_name> <version> [assembly_files...]
# @DESCRIPTION:
# Install a pkg-config file for a Mono assembly
einstall_pc_file() {
	local assembly_name=$1
	local version=$2
	shift 2
	local assembly_files=("$@")
	
	local pc_file="${T}/${assembly_name}.pc"
	
	# Create pkg-config file content
	cat > "${pc_file}" <<-_EOF_
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/$(get_libdir)
datarootdir=\${prefix}/share
datadir=\${datarootdir}
mono_libdir=\${libdir}/mono
monodir=\${mono_libdir}/gac
assembly_version=${version}.0

Name: ${assembly_name}
Description: ${assembly_name} assembly
Version: ${version}
Libs: $(printf -- '-r:%s ' "${assembly_files[@]}")
_EOF_

	# Install the pkg-config file
	insinto "/usr/$(get_libdir)/pkgconfig"
	newins "${pc_file}" "${assembly_name}.pc"
}

# @FUNCTION: einstall_pc_assembly
# @USAGE: <assembly_name> <version> [assembly_path]
# @DESCRIPTION:
# Install a pkg-config file specifically for an assembly
einstall_pc_assembly() {
	local assembly_name=$1
	local version=$2
	local assembly_path=$3
	
	if [[ -n "${assembly_path}" ]]; then
		einstall_pc_file "${assembly_name}" "${version}" "${assembly_path}"
	else
		local default_path="/usr/$(get_libdir)/mono/gac/${assembly_name}/${version}.0__$(token)/${assembly_name}.dll"
		einstall_pc_file "${assembly_name}" "${version}" "${default_path}"
	fi
}