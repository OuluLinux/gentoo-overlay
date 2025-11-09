# OuluLinux Gentoo Overlay

Packages currently available in this overlay:

- **dev-cpp/upp**
  - Ultimate++ application framework and TheIDE development environment
  - https://www.ultimatepp.org/
- **games-fps/ecwolf**
  - Modern Wolfenstein 3D source port with SDL2 backend
  - https://maniacsvault.net/ecwolf/
- **games-fps/tesseract-sauerbraten**
  - Sauerbraten with the Tesseract graphics update
  - https://github.com/OuluLinux/Tesseract-Sauerbraten

## Installation

1. Create the overlay definition `/etc/portage/repos.conf/oululinux.conf` (or any file under `repos.conf`).
2. Add the following repository configuration:

```
[oululinux]
location = /var/db/repos/oululinux
sync-type = git
sync-uri = https://github.com/oululinux/gentoo-overlay.git
```

3. Sync the new overlay:

```bash
emaint sync -r oululinux
```

If you already have `/home/sblo/gentoo-overlay` checked out locally and prefer to use it directly rather than syncing, point Portage at that path and tell it not to sync. For example, in `/etc/portage/repos.conf/oululinux.conf` use:

```
[oululinux]
location = /home/sblo/gentoo-overlay
sync-type = none
```


Portage 3.0 and later no longer accept `sync-type = none`. To keep using the local checkout without syncing, either add the overlay path to `PORTDIR_OVERLAY` (as above) or configure the repo with a supported sync type such as `git` (and a matching `sync-uri`, e.g. `https://github.com/oululinux/gentoo-overlay.git`).<div></div>

4. Install a package, for example:

```bash
emerge --ask dev-cpp/upp
```
