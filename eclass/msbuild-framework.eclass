# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: msbuild-framework.eclass
# @MAINTAINER:
# .NET Project <dotnet@gentoo.org>
# @AUTHOR:
# Original author unknown
# @SUPPORTED_EAPIS: 7 8
# @BLURB: Eclass providing MSBuild framework locations and utilities
# @DESCRIPTION:
# This eclass provides standard locations and utilities for MSBuild-based packages.

case ${EAPI:-0} in
	7|8) ;;
	*) die "${ECLASS}: EAPI ${EAPI} not supported" ;;
esac

# @ECLASS-VARIABLE: MSBUILD_TARGETS
# @DEFAULT_UNSET
# @DESCRIPTION:
# Targets for MSBuild, used to determine which version should be active

# @FUNCTION: msbuild_expand
# @USAGE: <target>
# @DESCRIPTION:
# Expand MSBuild target names to USE flag format
msbuild_expand() {
	local target=$1
	if [[ -n ${target} ]]; then
		echo "msbuild_targets_${target//./-}"
	else
		die "msbuild_expand: no target provided"
	fi
}

# @FUNCTION: dotnet_expand
# @USAGE: <framework>
# @DESCRIPTION:
# Expand .NET framework names to USE flag format
dotnet_expand() {
	local framework=$1
	if [[ -n ${framework} ]]; then
		echo "${framework//./_}"
	else
		die "dotnet_expand: no framework provided"
	fi
}

# @FUNCTION: MSBuildBinPath
# @DESCRIPTION:
# Get the MSBuild binary directory path
MSBuildBinPath() {
	echo "/usr/$(get_libdir)/mono/msbuild/$(get_MSBuildToolsVersion)"
}

# @FUNCTION: MSBuildSdksPath
# @DESCRIPTION:
# Get the MSBuild SDKs directory path
MSBuildSdksPath() {
	echo "/usr/$(get_libdir)/mono/msbuild/Sdks"
}

# @FUNCTION: MSBuildExtensionsPath
# @DESCRIPTION:
# Get the MSBuild extensions directory path
MSBuildExtensionsPath() {
	echo "/usr/$(get_libdir)/mono/msbuild"
}

# @FUNCTION: MSBuildToolsPath
# @DESCRIPTION:
# Get the MSBuild tools directory path
MSBuildToolsPath() {
	echo "/usr/$(get_libdir)/mono/msbuild/$(get_MSBuildToolsVersion)"
}

# @FUNCTION: get_MSBuildToolsVersion
# @DESCRIPTION:
# Get the MSBuild tools version based on SLOT
get_MSBuildToolsVersion() {
	local slot_version="${SLOT}"
	if [[ "${slot_version}" =~ ^([0-9]+)\.([0-9]+) ]]; then
		echo "${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
	else
		# Default to 15.0 if slot is not in X.Y format
		echo "15.0"
	fi
}

# @FUNCTION: RoslynTargetsPath
# @DESCRIPTION:
# Get the Roslyn targets directory path
RoslynTargetsPath() {
	echo "/usr/$(get_libdir)/mono/msbuild/Roslyn"
}

# @ECLASS-VARIABLE: MSBuildBinPath
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# The location where MSBuild binaries are installed.

# @ECLASS-VARIABLE: MSBuildSdksPath
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# The location where MSBuild SDKs are installed.

# @ECLASS-VARIABLE: MSBuildExtensionsPath
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# The location where MSBuild extensions are installed.

# @ECLASS-VARIABLE: MSBuildToolsPath
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# The location where MSBuild tools are installed.

# @ECLASS-VARIABLE: RoslynTargetsPath
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# The location where Roslyn targets are installed.

# Variables are provided as functions since they cannot be computed at global scope

# @FUNCTION: reference_dependency
# @USAGE: <assembly_name>
# @DESCRIPTION:
# Generate reference flag for MSBuild dependency
reference_dependency() {
	local assembly_name=$1
	local version=${2:-$(get_best_version_for_assembly "${assembly_name}")}
	
	# Extract package name and version from assembly name like "Microsoft.Build.Framework-17.14"
	if [[ ${assembly_name} =~ ^([^-]+)-([0-9]+\.[0-9]+) ]]; then
		local pkg_name="${BASH_REMATCH[1]}"
		local pkg_version="${BASH_REMATCH[2]}"
		
		echo "-reference:/usr/$(get_libdir)/mono/gac/${pkg_name}/${pkg_version}.0.0__$(get_token_for_package "${pkg_name}")/${pkg_name}.dll"
	else
		echo "-reference:/usr/$(get_libdir)/mono/gac/${assembly_name}/${version}/${assembly_name}.dll"
	fi
}

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

# @FUNCTION: get_token_for_package
# @INTERNAL
# @DESCRIPTION:
# Get token for a specific package
get_token_for_package() {
	# For now, return the standard Mono token
	echo "0738eb9f132ed756"
}

# @FUNCTION: get_best_version_for_assembly
# @INTERNAL
# @DESCRIPTION:
# Find the best installed version for an assembly
get_best_version_for_assembly() {
	local assembly_name=$1
	# This is a simplified implementation
	# In a real implementation, this would search for installed versions
	echo "0.0.0.0__0000000000000000"
}