#!/bin/bash -x
### Build a docker image for ubuntu i386.

### settings
arch=i386
suite=trusty
chroot_dir='/var/chroot/trusty'
apt_mirror='http://archive.ubuntu.com/ubuntu'
docker_image='32bit/ubuntu-14.04'

### make sure that the required tools are installed
apt-get install -y docker.io debootstrap dchroot

### install a minbase system with debootstrap
export DEBIAN_FRONTEND=noninteractive
debootstrap --variant=minbase --arch=$arch $suite $chroot_dir $apt_mirror

### update the list of package sources
cat <<EOF > $chroot_dir/etc/apt/sources.list
deb $apt_mirror trusty main restricted universe multiverse
deb $apt_mirror trusty-updates main restricted universe multiverse
deb $apt_mirror trusty-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu trusty-security main restricted universe multiverse
deb http://extras.ubuntu.com/ubuntu trusty main
EOF

### install ubuntu-minimal
cp /etc/resolv.conf $chroot_dir/etc/resolv.conf
mount -o bind /proc $chroot_dir/proc
chroot $chroot_dir apt-get update
chroot $chroot_dir apt-get -y install ubuntu-minimal

### cleanup and unmount /proc
chroot $chroot_dir apt-get autoclean
chroot $chroot_dir apt-get clean
chroot $chroot_dir apt-get autoremove
rm $chroot_dir/etc/resolv.conf
umount $chroot_dir/proc

### create a tar archive from the chroot directory
tar cfz ubuntu.tgz -C $chroot_dir .

### import this tar archive into a docker image:
cat ubuntu.tgz | docker import - $docker_image

# ### push image to Docker Hub
# docker push $docker_image

# ### cleanup
# rm ubuntu.tgz
# rm -rf $chroot_dir
