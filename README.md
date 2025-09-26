# OuluLinux Gentoo Overlay

The OuluLinux Gentoo Overlay repo, contains the following:

- **games-fps/tesseract-sauerbraten**
  - Sauerbraten with graphics update of tesseract
  - [https://github.com/OuluLinux/Tesseract-Sauerbraten](https://github.com/OuluLinux/Tesseract-Sauerbraten)

# Installation

1. Create the overlay's metadata file `/etc/portage/repos.conf/oululinux.conf`
2. Add the overlay's metadata to the created file

```
[oululinux]
location = /var/db/repos/oululinux
sync-type = git
sync-uri = https://github.com/oululinux/gentoo-overlay.git
```

3. Sync the new overlay

```bash
; emerge --sync oululinux-overlay
```
