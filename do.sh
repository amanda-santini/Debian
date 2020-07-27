#/bin/bash
## Original by tuxutku (https://gist.github.com/tuxutku/79daa2edca131c1525a136b650cdbe0a)
## Modified by haxpor (https://gist.github.com/haxpor/8533fde401853615f4b2e4510048a319)
prefix='amdgpu-pro-'
postfix='-ubuntu-20.04'
major='20.20'
minor='1098277'
shared="opt/amdgpu-pro/lib/x86_64-linux-gnu"
srcdir="$(pwd)"
pkgdir="${srcdir}/pkgdir"
mkdir -p "${pkgdir}"
cd "${srcdir}"

# AMD website check whether you're from the donwloading page in order to successfully download a target driver file
echo "Downloading archive and extracting"
wget --header="Referer: https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-20" --header="Host: drivers.amd.com" --header="User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" --header="Accept-Encoding: gzip, deflate, br" -N -O - "https://drivers.amd.com/drivers/linux/${major}/${prefix}${major}-${minor}${postfix}.tar.xz"| tar -xJ
echo "Extraction complete, creating the files"

mkdir -p "${srcdir}/opencl"
cd "${srcdir}/opencl"
ar x "${srcdir}/${prefix}${major}-${minor}${postfix}/opencl-amdgpu-pro-icd_${major}-${minor}_amd64.deb"
tar xJf data.tar.xz
ar x "${srcdir}/${prefix}${major}-${minor}${postfix}/opencl-orca-amdgpu-pro-icd_${major}-${minor}_amd64.deb"
tar xJf data.tar.xz
cd ${shared}

# this prevents conflict that might happen later if you install AMD driver
sed -i "s|libdrm_amdgpu|libdrm_amdgpo|g" libamdocl-orca64.so

mkdir -p "${srcdir}/libdrm"
cd "${srcdir}/libdrm"
ar x "${srcdir}/${prefix}${major}-${minor}${postfix}/libdrm-amdgpu-amdgpu1_2.4.100-${minor}_amd64.deb"
tar xJf data.tar.xz
cd ${shared/amdgpu-pro/amdgpu}
rm "libdrm_amdgpu.so.1"
mv  "libdrm_amdgpu.so.1.0.0" "libdrm_amdgpo.so.1.0.0"
ln -s "libdrm_amdgpo.so.1.0.0" "libdrm_amdgpo.so.1"

mv  "${srcdir}/opencl/etc" "${pkgdir}/"
mkdir -p ${pkgdir}/usr/lib
mv "${srcdir}/opencl/${shared}/libamdocl64.so" "${pkgdir}/usr/lib/"
mv "${srcdir}/opencl/${shared}/libamdocl-orca64.so" "${pkgdir}/usr/lib/"
mv "${srcdir}/opencl/${shared}/libamdocl12cl64.so" "${pkgdir}/usr/lib/"
mv "${srcdir}/libdrm/${shared/amdgpu-pro/amdgpu}/libdrm_amdgpo.so.1.0.0" "${pkgdir}/usr/lib/"
mv "${srcdir}/libdrm/${shared/amdgpu-pro/amdgpu}/libdrm_amdgpo.so.1" "${pkgdir}/usr/lib/"

mkdir -p "${pkgdir}/opt/amdgpu/share/libdrm"
cd "${pkgdir}/opt/amdgpu/share/libdrm"
ln -s /usr/share/libdrm/amdgpu.ids amdgpu.ids

rm -r "${srcdir}/opencl"
rm -r "${srcdir}/libdrm"
cd "${pkgdir}"

echo "done"

echo "Creating files complete, copying files to root. Enter sudo password when asked"
sudo cp -Rv * /
# need to replace this shared library to make it work
sudo cp -p "usr/lib/libamdocl64.so" /opt/rocm/opencl/lib/libamdocl64.so
sudo cp -p "usr/lib/libamdocl64.so" /opt/rocm-3.5.0/opencl/lib/libamdocl64.so
#echo Warning: remember to remove \'mesa-opencl-icd\' \!, otherwise you will have each device in both opencl 1.1 and 1.2 modes as seperate devices . clpeak for example will report each gpu twice \! This is problematic for BOINC
