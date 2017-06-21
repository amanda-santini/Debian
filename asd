# as root

apt-get install build-essential fakeroot
apt-get build-dep linux
apt-get install devscripts

# as regular user

mkdir Documents/Kernels/Rebuild
cd Documents/Kernels/Rebuild
apt-get source linux
cd Documents/Kernels/Rebuild/linux-4.9.30/debian/patches/bugfix/all/
wget https://raw.githubusercontent.com/amarildojr/Kernels/master/4.9-staging/Build/dpm2.patch
wget https://raw.githubusercontent.com/amarildojr/Kernels/master/4.9-staging/Build/dpm.patch
cd linux/linux-4.9.30/
patch -p1 < debian/patches/bugfix/all/dpm.patch
patch -p1 < debian/patches/bugfix/all/dpm2.patch
make clean && make mrproper
cp /boot/config-`uname -r` ./.config
make deb-pkg -j 6


fakeroot make-kpkg --initrd --append-to-version=-custom kernel_image kernel_headers -j 6
