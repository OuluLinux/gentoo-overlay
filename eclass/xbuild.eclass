# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: xbuild.eclass
# @MAINTAINER:
# .NET Project <dotnet@gentoo.org>
# @AUTHOR:
# Michał Górny <mgorny@gentoo.org>
# @SUPPORTED_EAPIS: 7 8
# @BLURB: Eclass for building .NET software with xbuild or msbuild
# @DESCRIPTION:
# This eclass provides functions for building .NET software with either xbuild or msbuild.
# It handles the configuration for Mono-based builds.

case ${EAPI:-0} in
	7|8) ;;
	*) die "${ECLASS}: EAPI ${EAPI} not supported" ;;
esac

inherit dotnet

EXPORT_FUNCTIONS src_compile src_install

# @ECLASS-VARIABLE: XBUILD
# @DEFAULT_UNSET
# @DESCRIPTION:
# The command to use for building. Will be automatically set if unset.

# @ECLASS-VARIABLE: XBUILD_FLAGS
# @DEFAULT_UNSET
# @DESCRIPTION:
# Additional flags to pass to the xbuild command.

# @FUNCTION: xbuild_src_compile
# @DESCRIPTION:
# Default src_compile function using xbuild
xbuild_src_compile() {
	local build_tool=${XBUILD:-xbuild}

	if [[ -z ${XBUILD} ]]; then
		if has_version ">=dev-util/msbuild-15"; then
			XBUILD="msbuild"
		else
			XBUILD="xbuild"
		fi
	fi

	local xbuild_cmd="${XBUILD}"
	[[ -n ${XBUILD_FLAGS} ]] && xbuild_cmd+=" ${XBUILD_FLAGS}"

	# Default compile action - can be overridden
	# Usually called with specific project files or solutions
	if [[ $# -eq 0 ]]; then
		# Default behavior: build the first found solution or project 
		local proj_files=()
		for file in *.sln *.csproj *.vbproj *.fsproj; do
			[[ -f "$file" ]] && proj_files+=("$file")
		done
		if [[ -n "${proj_files[0]}" ]] && [[ -f "${proj_files[0]}" ]]; then
			${xbuild_cmd} "${proj_files[0]}" || die "${xbuild_cmd} failed"
		else
			# Return without error - let the ebuild handle build internally
			return 0
		fi
	else
		${xbuild_cmd} "$@" || die "${xbuild_cmd} failed"
	fi
}

# @FUNCTION: xbuild_src_install
# @DESCRIPTION:
# Default src_install function for xbuild packages
xbuild_src_install() {
	# Default install - copy built assemblies to appropriate directories
	dotnet_src_install

	# Install any built executables
	if [[ -d bin ]]; then
		find bin -type f -executable -name "*.exe" -exec install -Dm755 {} "${D}"/usr/bin/ \;
	fi
}

# @FUNCTION: exbuild_raw
# @USAGE: [args...]
# @DESCRIPTION:
# Execute xbuild/msbuild with raw arguments
exbuild_raw() {
	local build_tool
	if has_version ">=dev-util/msbuild-15"; then
		build_tool="msbuild"
	else
		build_tool="xbuild"
	fi

	"${build_tool}" "$@" || die "${build_tool} failed"
}

# Set default values
XBUILD_FLAGS="${XBUILD_FLAGS:--nologo}"

# @FUNCTION: reference_framework
# @USAGE: <assembly_name>
# @DESCRIPTION:
# Generate reference flag for framework assembly
reference_framework() {
	local assembly_name=$1
	echo "-reference:/usr/lib/mono/4.0/${assembly_name}.dll"
}

# @FUNCTION: output_dll
# @USAGE: <assembly_name>
# @DESCRIPTION:
# Generate output flag for DLL compilation
output_dll() {
	local assembly_name=$1
	echo "-target:library -out:$(bin_dir)/$(usedebug_tostring)/${assembly_name}.dll"
}

# @FUNCTION: bin_dir
# @DESCRIPTION:
# Get the binary output directory
bin_dir() {
	echo "${WORKDIR}/bin"
}

# @FUNCTION: usedebug_tostring
# @DESCRIPTION:
# Convert debug USE flag to configuration string
usedebug_tostring() {
	if use debug; then
		echo "Debug"
	else
		echo "Release"
	fi
}

# @FUNCTION: csharp_sources
# @USAGE: [directory]
# @DESCRIPTION:
# Get all C# source files from a directory
csharp_sources() {
	local dir=$1
	if [[ -n "${dir}" ]]; then
		for file in "${dir}"/*.cs; do
			[[ -f "${file}" ]] && echo -n " \"${file}\" "
		done
	else
		for file in *.cs; do
			[[ -f "${file}" ]] && echo -n " \"${file}\" "
		done
	fi
}