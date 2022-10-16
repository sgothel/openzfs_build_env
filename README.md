# OpenZFS Build Environment

[Original document location](https://jausoft.com/cgit/openzfs/openzfs_build_env.git/about/).

Current environment covers [OpenZFS](https://openzfs.github.io/openzfs-docs/) 
for GNU/Linux version [2.1.6](https://github.com/openzfs/zfs/releases/tag/zfs-2.1.6).

## Debian Dependencies

Install build dependencies, tested with Debian 11 and 12.

```bash
apt install build-essential autoconf automake libtool gawk alien fakeroot dkms libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev linux-headers-generic python3 python3-dev python3-setuptools python3-cffi libffi-dev python3-packaging git libcurl4-openssl-dev

apt install linux-headers-amd64 libselinux-dev parted lsscsi wget ksh gdebi python3-distutils
```


## Pull sources

Fetching the [original sources](https://github.com/openzfs/zfs).

```bash
git clone https://github.com/openzfs/zfs
cd zfs
git checkout -b b_zfs-2.1.6 zfs-2.1.6
cd ..
```

## Build

The following is captured within `make-all.sh` script.

```bash
mkdir -p build

cd zfs
# select branch/tag ..
./autogen.sh
# ./configure --with-config=srpm
./configure --enable-systemd
# make pkg-utils deb-dkms
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
  - grub-install /dev/disk/by-id/your_boot_root_device

## ZFS Compatibility Settings 

Following compatibility feature sets have been tested

- Read-Only Feature Sets `etc/zfs/compatibility.d/readonly`
- Extended GRUB2 and Read-Only Feature Sets `etc/zfs/compatibility.d/grub2_readonly`

