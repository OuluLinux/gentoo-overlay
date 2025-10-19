# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gac.eclass
# @MAINTAINER:
# .NET Project <dotnet@gentoo.org>
# @AUTHOR:
# Michał Górny <mgorny@gentoo.org>
# @SUPPORTED_EAPIS: 7 8
# @BLURB: Eclass for Global Assembly Cache (GAC) operations
# @DESCRIPTION:
# This eclass provides functions for installing and managing .NET assemblies in the Global Assembly Cache.

case ${EAPI:-0} in
	7|8) ;;
	*) die "${ECLASS}: EAPI ${EAPI} not supported" ;;
esac

inherit dotnet

# @FUNCTION: egacinstall
# @USAGE: <assembly>
# @DESCRIPTION:
# Install an assembly to the GAC with proper naming and versioning.
egacinstall() {
	local assembly_file=$1
	[[ -z "${assembly_file}" ]] && die "egacinstall: no assembly file specified"

	if [[ ! -f "${assembly_file}" ]]; then
		eerror "Assembly file does not exist: ${assembly_file}"
		die "Assembly file does not exist: ${assembly_file}"
	fi

	local assembly_name=$(basename "${assembly_file}")
	local assembly_name_only="${assembly_name%.*}"
	
	einfo "Installing ${assembly_name} to Global Assembly Cache"
	
	# Use gacutil to install to GAC
	gacutil -i "${assembly_file}" || die "Failed to install ${assembly_name} to GAC"
	
	# Also install to the regular location for fallback - using a default version and token
	insinto "/usr/$(get_libdir)/mono/gac/${assembly_name_only}/0.0.0.0__$(token)"
	newins "${assembly_file}" "${assembly_name}"
}

# @FUNCTION: egacremove
# @USAGE: <assembly_name>
# @DESCRIPTION:
# Remove an assembly from the GAC.
egacremove() {
	local assembly_name=$1
	[[ -z "${assembly_name}" ]] && die "egacremove: no assembly name specified"
	
	einfo "Removing ${assembly_name} from Global Assembly Cache"
	gacutil -u "${assembly_name}" || eerror "Failed to remove ${assembly_name} from GAC"
}

# @FUNCTION: token
# @DESCRIPTION:
# Get or generate token for assembly signing
token() {
	local token_file="${WORKDIR}/token.txt"
	if [[ -f "${token_file}" ]]; then
		cat "${token_file}"
	else
		# Default token for unsigned builds or get from key file
		if [[ -f "${FILESDIR}/mono.snk" ]]; then
			# Extract from mono.snk if available
			echo "0738eb9f132ed756"
		else
			echo "0000000000000000"  # Default unsigned token
		fi
	fi
}

# @FUNCTION: token_key
# @DESCRIPTION:
# Get path to token key file for assembly signing
token_key() {
	if [[ -f "${DISTDIR}/mono.snk" ]]; then
		echo "${DISTDIR}/mono.snk"
	elif [[ -f "${FILESDIR}/mono.snk" ]]; then
		echo "${FILESDIR}/mono.snk"
	else 
		die "No signing key file found"
	fi
}

# @FUNCTION: signing_key
# @DESCRIPTION:
# Get path to signing key file
signing_key() {
	token_key
}