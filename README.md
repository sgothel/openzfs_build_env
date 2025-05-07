# OpenZFS Build Environment

[Original document location](https://jausoft.com/cgit/openzfs/openzfs_build_env.git/about/).

Current environment covers [OpenZFS](https://openzfs.github.io/openzfs-docs/)
for GNU/Linux version [2.3.2](https://github.com/openzfs/zfs/releases/tag/zfs-2.3.2).

I also host branches with [Debian build fixes](https://jausoft.com/cgit/openzfs/zfs.git).

## Debian 13 Notes
Warning, OpenZFS 2.2.7 and 2.3.0-rc3 won't get compiled under Debian 13 currently.
This is probably due to `rpmbuilder` spec mismatch.

However, build for Debian 12 work well under Debian 13.

## Debian Dependencies

### Debian 12
Install build dependencies, tested with Debian 12
following [OpenZFS's Building ZFS](https://openzfs.github.io/openzfs-docs/Developer%20Resources/Building%20ZFS.html).

```bash
sudo apt install alien autoconf automake build-essential debhelper-compat dh-autoreconf dh-dkms dh-python dkms fakeroot gawk git libaio-dev libattr1-dev libblkid-dev libcurl4-openssl-dev libelf-dev libffi-dev libpam0g-dev libssl-dev libtirpc-dev libtool libudev-dev linux-headers-generic parallel po-debconf python3 python3-all-dev python3-cffi python3-dev python3-packaging python3-setuptools python3-sphinx uuid-dev zlib1g-dev

apt install linux-headers-amd64 libselinux-dev parted lsscsi wget ksh gdebi python3-distutils
```

#### Grub2 2.12 Backport
See [Debian Using backports](https://wiki.debian.org/Backports#Using_backports)
- Add /etc/apt/sources.list
```
deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
```
- Update package database and show `grub2` packages
```
apt update
apt show grub2 -a
```
- Install `grub2` 2.12 backport
```
apt install grub2/bookworm-backports
```

### Debian 13
Install build dependencies for Debian 13
following [OpenZFS's Building ZFS](https://openzfs.github.io/openzfs-docs/Developer%20Resources/Building%20ZFS.html).

```bash
sudo apt install alien autoconf automake build-essential debhelper-compat dh-autoreconf dh-dkms dh-python dkms fakeroot gawk git libaio-dev libattr1-dev libblkid-dev libcurl4-openssl-dev libelf-dev libffi-dev libpam0g-dev libssl-dev libtirpc-dev libtool libudev-dev linux-headers-generic parallel po-debconf python3 python3-all-dev python3-cffi python3-dev python3-packaging python3-setuptools python3-sphinx uuid-dev zlib1g-dev

apt install linux-headers-amd64 libselinux-dev parted lsscsi wget ksh gdebi python3-distutils-extra
```

## Pull sources

### OpenZFS Source
Fetching the [original sources](https://github.com/openzfs/zfs).

```bash
git clone https://github.com/openzfs/zfs
cd zfs
git checkout -b b_zfs-2.3.2 zfs-2.3.2
cd ..
```

### With Debian <= 12 Build Fix
Fetching the [jausoft branch](git://jausoft.com/srv/scm/openzfs/zfs.git)

```bash
git clone git://jausoft.com/srv/scm/openzfs/zfs.git
cd zfs
git checkout -b b_zfs_2.3.2_debian12 --track origin/b_zfs_2.3.2_debian12
cd ..
```

## Build

The following is captured within [make-all.sh](./make-all.sh) script,
which shall be invoked within this `openzfs_build_env` directory.

```bash
mkdir -p build

cd zfs
git clean -d -f -x
./autogen.sh
./configure --enable-systemd
make -j$(nproc)
make -j1 deb
mv *.tar.gz *.deb ../build
make clean
cd ..
```

## Convenience scrips

You can find convenient removal and install scripts within `scripts` folder.
- `scripts`: ZFS debian package remova and install scripts
- `rescue`: Manual ZFS rescue scripts
- `setup`: Misc ZFS setup and tuning scripts

### Manual ZFS Rescue

Documented shell script `rescue/chroot_mount.sh` shows how-to
- auto import local zfs pools
- chroot into the imported root filesystem
  - bind special devices and pipes to zfs realm
  - chroot into the zfs system
- shows three typical recovery tasks
  - update-initramfs -u -k all
  - update-grub
  - grub-install /dev/disk/by-id/your\_boot\_root\_device
    - perhaps repeat this for all your ZFS pool devices

### Update Procedure

The following procedure covers the openzfs update procedure.

```bash
cd openzfs_build_env

# Uninstall old zfs packages
sh scripts/zfs-remove.sh

# Install new zfs packages
sh scripts/zfs-2.3.2-1-install-debian12-amd64.sh

# Update /etc/default/zfs
cd /etc/default/
diff zfs.cpy zfs
vi zfs.cpy zfs

# Regenerate initrd files for booting
update-initramfs -u -k all
```

## ZFS Compatibility Settings

Following compatibility feature sets have been tested

- Read-Only Feature Sets `etc/zfs/compatibility.d/readonly`
- Extended GRUB2 and Read-Only Feature Sets `etc/zfs/compatibility.d/grub2_readonly`
  - Best to install `grub2` version >= 2.12, e.g. Debian 12 Backport (see above)

