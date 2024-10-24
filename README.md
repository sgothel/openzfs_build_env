# OpenZFS Build Environment

[Original document location](https://jausoft.com/cgit/openzfs/openzfs_build_env.git/about/).

Current environment covers [OpenZFS](https://openzfs.github.io/openzfs-docs/)
for GNU/Linux version [2.2.6](https://github.com/openzfs/zfs/releases/tag/zfs-2.2.6).

I also host branches with [Debian build fixes](https://jausoft.com/cgit/openzfs/zfs.git).

## Debian Dependencies

Install build dependencies, tested with Debian 12
following [OpenZFS's Building ZFS](https://openzfs.github.io/openzfs-docs/Developer%20Resources/Building%20ZFS.html).

```bash
sudo apt install alien autoconf automake build-essential debhelper-compat dh-autoreconf dh-dkms dh-python dkms fakeroot gawk git libaio-dev libattr1-dev libblkid-dev libcurl4-openssl-dev libelf-dev libffi-dev libpam0g-dev libssl-dev libtirpc-dev libtool libudev-dev linux-headers-generic parallel po-debconf python3 python3-all-dev python3-cffi python3-dev python3-packaging python3-setuptools python3-sphinx uuid-dev zlib1g-dev

apt install linux-headers-amd64 libselinux-dev parted lsscsi wget ksh gdebi python3-distutils
```



## Pull sources

### OpenZFS Source
Fetching the [original sources](https://github.com/openzfs/zfs).

```bash
git clone https://github.com/openzfs/zfs
cd zfs
git checkout -b b_zfs-2.2.6 zfs-2.2.6
cd ..
```

### With Debian Build Fix
Fetching the [jausoft branch](git://jausoft.com/srv/scm/openzfs/zfs.git)

```bash
git clone git://jausoft.com/srv/scm/openzfs/zfs.git
cd zfs
git checkout -b b_zfs_2.2.6 --track origin/b_zfs_2.2.6
cd ..
```

## Build

The following is captured within `make-all.sh` script.

```bash
mkdir -p build

cd zfs
git clean -d -f -x
# select branch/tag ..
./autogen.sh
./configure --enable-systemd
make -j$(nproc)
make -j1 deb-utils deb-dkms
mv *.tar.gz *.deb ../build
make clean
rm -f *.rpm
cd ..
```

## Convenience scrips

You can find convenient removal and install scripts within `scripts` folder.
- `scripts`: ZFS debian package remova and install scripts
- `rescue`: Manual ZFS rescue scripts
- `setup`: Misc ZFS setup and tuning scripts

### Manual ZFS Rescue

Documented shell script `rescue/chroot_zfs.sh` shows how-to
- auto import local zfs pools
- chroot into the imported root filesystem
  - bind special devices and pipes to zfs realm
  - chroot into the zfs system
- shows three typical recovery tasks
  - update-initramfs -u -k all
  - update-grub
  - grub-install /dev/disk/by-id/your\_boot\_root\_device
    - perhaps repeat this for all your ZFS pool devices

## ZFS Compatibility Settings

Following compatibility feature sets have been tested

- Read-Only Feature Sets `etc/zfs/compatibility.d/readonly`
- Extended GRUB2 and Read-Only Feature Sets `etc/zfs/compatibility.d/grub2_readonly`

