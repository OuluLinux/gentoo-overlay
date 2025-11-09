## Next Steps
- Read the outstanding Gentoo news item with `eselect news read`; festival now builds and installs without failures, so no other changes are pending.

## Progress
- Switched the festival ebuild to GitHub commit tarballs (`festival-2.5.1` + `speech_tools-2.5.1`), renamed the ebuild/Manifest, and reorganized `src_unpack/src_prepare` to rename directories, patch `speech_tools`, and auto-generate `speech_tools/config/config`.
- Added logic to generate `speech_tools/base_class/inst_tmpl/force_instantiations.cc` and insert it into the `Makefile`, ensuring the new template instantiations are compiled without requiring `epatch.eclass`.
- Fixed `speech_tools/siod/editline.c` by including `<term.h>`, updating `substrcmp`/`search_hist` to use C++-friendly prototypes (`size_t`, `const` pointers, and explicit `match` signatures), and patching the forward declaration so `g++` no longer complains about the termcap functions.
- After updating `speech_tools/config/config` to use `TERMCAPLIB = -lncurses -ltinfo` and dropping the QA-triggering `var/tmp/portage/.../image` subtree in `src_install`, `sudo emerge -v festival` now finishes cleanly.

## Related Information
- Build log: `/var/tmp/portage/app-accessibility/festival-2.5.1/temp/build.log` existed for the last run but Portage removed it after a successful install; reruns will generate a new log in the same path if needed.
