# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
RESTRICT="mirror"

SLOT="$(ver_cut 1-2)"

SLOT_OF_API="${SLOT}" # slot for ebuild with API of msbuild
VER="${PV}" # version of resulting msbuild.exe

USE_DOTNET="net46"
IUSE="+${USE_DOTNET} +gac +mskey developer debug +roslyn symlink"

inherit wrapper
inherit xbuild 
inherit gac 

# msbuild-framework.eclass is inherited to get the access to the locations 
# $(MSBuildBinPath) and $(MSBuildSdksPath)
inherit msbuild-framework

GITHUB_ACCOUNT="dotnet"
GITHUB_PROJECTNAME="msbuild"
EGIT_COMMIT="7f2c52460dca9d2b0c9c920e2af8e5f55de69f00"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${PV}.tar.gz
\tmskey? ( https://github.com/dotnet/msbuild/raw/main/src/MSFT.snk )
\thttps://github.com/mono/mono/raw/main/mcs/class/mono.snk
\t"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/dotnet/msbuild"
DESCRIPTION="Microsoft Build Engine (MSBuild) is an XML-based platform for building applications"
LICENSE="MIT" # https://github.com/dotnet/msbuild/blob/main/LICENSE

COMMON_DEPEND=">=dev-lang/mono-6.12.0.178
\tdev-dotnet/msbuild-tasks-api:${SLOT_OF_API} developer? ( dev-dotnet/msbuild-tasks-api:${SLOT_OF_API}[developer] )
\tdev-dotnet/msbuild-defaulttasks:${SLOT_OF_API} developer? ( dev-dotnet/msbuild-defaulttasks:${SLOT_OF_API}[developer] )
\troslyn? ( dev-mono/msbuild-roslyn-csc )
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
\tdev-dotnet/buildtools
"

PROJ1=Microsoft.Build
PROJ1_DIR=src/Build
PROJ2=MSBuild
PROJ2_DIR=src/MSBuild

src_prepare() {
	REGEX1='s*\${SLOT}*'${SLOT}'*g'
	sed -E ${REGEX1} "${FILESDIR}/${PV}/MSBuild.exe.config" > "${T}/MSBuild.exe.config" || die
	einfo "PublicKeyToken=$(token)"
	REGEX2='s/PublicKeyToken=[0-9a-f]+/PublicKeyToken='$(token)'/g'
	sed -E ${REGEX2} "${FILESDIR}/${PV}/mono-${PROJ1}.csproj" > "${S}/${PROJ1_DIR}/mono-${PROJ1}.csproj" || die
	sed -E ${REGEX2} "${FILESDIR}/${PV}/mono-${PROJ2}.csproj" > "${S}/${PROJ2_DIR}/mono-${PROJ2}.csproj" || die
	sed -E ${REGEX2} -i "${S}/src/MSBuild/app.config" || die
	sed -E ${REGEX2} -i ${S}/src/Build/Resources/Constants.cs || die
	sed -E ${REGEX2} -i ${S}/src/Tasks/Microsoft.Common.tasks || die
	sed -E ${REGEX2} -i ${S}/src/Tasks/Microsoft.Common.overridetasks || die
	sed "s/15.1./${SLOT}.0./g" -i "${S}/src/Shared/Constants.cs" || die
	sed "s/15.1./${SLOT}.0./g" -i "${S}/src/Tasks/Microsoft.Common.overridetasks" || die
	eapply_user
}

src_compile() {
	if use developer; then
		SARGS=/p:DebugSymbols=True
	else
		SARGS=/p:DebugSymbols=False
	fi

	if use debug; then
		if use developer; then
			SARGS=${SARGS} /p:DebugType=full
		fi
	else
		if use developer; then
			SARGS=${SARGS} /p:DebugType=pdbonly
		fi
	fi

	local PROPERTIES=(
		"/p:TargetFrameworkVersion=v4.6"
		"/p:Configuration=$(usedebug_tostring)"
		"/p:VersionNumber=${VER}"
		"/p:ReferencesVersion=${SLOT_OF_API}.0.0" 
		"/p:RootPath=${S}"
		"/p:MonoBuild=true"
		"/p:SignAssembly=true"
		"/p:DelaySign=true"
		"/p:AssemblyOriginatorKeyFile=$(token_key)"
		"/p:PublicKeyToken=$(token)"
	)
	# see https://unix.stackexchange.com/questions/29509/transform-an-array-into-arguments-of-a-command
	# ${PROPERTIES[@]}

	exbuild_raw /v:detailed   ${PROPERTIES[@]} ${SARGS} "${S}/${PROJ2_DIR}/mono-${PROJ2}.csproj"
	sn -R "${PROJ1_DIR}/bin/$(usedebug_tostring)/${PROJ1}.dll" "$(signing_key)" || die
}

src_install() {
	TargetVersion=${SLOT}

	dodir "$(MSBuildExtensionsPath)"

	insinto "$(MSBuildExtensionsPath)"

	# dosym <filename> <linkname>
	#    Performs the ln command to create a symlink. 
	# Create a symlink to the target specified as the first parameter, at the path specified by the second parameter.
	# Note that the target is interpreted verbatim; it needs to either specify a relative path or an absolute path including ${EPREFIX}. 
	dosym "$(MSBuildExtensionsPath)/${SLOT}" "$(MSBuildBinPath)/15.0" 
        # this symlink to the same directory allows proper calculations in Microsoft.Managed.Core.targets file
	# 	when it tries to load "Microsoft.Common.props" file from the 15.0 toolset

	einfo "Deploying props into $(MSBuildExtensionsPath)/$(MSBuildToolsVersion)"
	insinto "$(MSBuildExtensionsPath)/$(MSBuildToolsVersion)"
	doins "${S}/src/Tasks/Microsoft.Common.props"

	einfo "Deploying targets into $(MSBuildBinPath)"
	insinto "$(MSBuildBinPath)"

	newins "${PROJ2_DIR}/bin/$(usedebug_tostring)/${PROJ2}.exe" MSBuild.exe

#	doins "${FILESDIR}/${PV}/MSBuild.exe.config"
	doins "${T}/MSBuild.exe.config"

	doins "${S}/src/Tasks/Microsoft.CSharp.targets"
	doins "${S}/src/Tasks/Microsoft.CSharp.CurrentVersion.targets"
	doins "${S}/src/Tasks/Microsoft.Common.targets"
	doins "${S}/src/Tasks/Microsoft.Common.CurrentVersion.targets"
	doins "${S}/src/Tasks/Microsoft.NETFramework.targets"
	doins "${S}/src/Tasks/Microsoft.NETFramework.CurrentVersion.targets"
	doins "${S}/src/Tasks/Microsoft.Common.overridetasks"
	doins "${S}/src/Tasks/Microsoft.NETFramework.props"
	doins "${S}/src/Tasks/Microsoft.NETFramework.CurrentVersion.props"

	keepdir "$(MSBuildSdksPath)"

	egacinstall "${PROJ1_DIR}/bin/$(usedebug_tostring)/${PROJ1}.dll"

	if use debug; then
		make_wrapper msbuild-${SLOT} "/usr/bin/mono --debug $(MSBuildBinPath)/MSBuild.exe"
	else
		make_wrapper msbuild-${SLOT} "/usr/bin/mono $(MSBuildBinPath)/MSBuild.exe"
	fi

	if use symlink; then
		dosym ${EPREFIX}/usr/bin/msbuild-${SLOT} /usr/bin/msbuild || die
	fi
}

pkg_postinst() {
	if ! has "msbuild${SLOT/./-}" ${MSBUILD_TARGETS}; then
		   elog "you will need to apend USE_EXPAND variable, like following"
		   elog "MSBUILD_TARGETS=msbuild${SLOT/./-}"
		   elog "in order to install Sdks for this version of msbuild."
	fi
}