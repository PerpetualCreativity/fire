from quay.io/fedora/fedora-bootc:41

run dnf -y install 'dnf5-command(config-manager)'

run <<EOF
useradd -G wheel vulcan
mkdir -m 0600 /home/core
chown -R vulcan: /home/core
echo temporary | passwd -s vulcan
EOF

# add ssh key
arg vulcan_pubkey
run <<EOF
if test -z "$vulcan_pubkey"; then
  echo "must provide vulcan's public key"
  exit 1
fi
EOF

run <<EOF
set -eu
echo -e "AuthorizedKeysFile /usr/ssh/%u.keys\nPasswordAuthentication no" >> /etc/ssh/sshd_config.d/30-auth-system.conf
mkdir -p /usr/ssh
echo $vulcan_pubkey > /usr/ssh/vulcan.keys && chmod +r /usr/ssh/vulcan.keys
EOF

# install tailscale
run <<EOF
set -eu
dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf -y install tailscale
systemctl enable tailscaled
EOF

# raspberry pi 4 only
# from https://github.com/ondrejbudai/fedora-bootc-raspi
# as ondrejbudai says, this is a pretty horrible workaround
# but we'll have to wait until bootupd is fixed
run <<EOF
set -eu
dnf install -y bcm2711-firmware uboot-images-armv8
cp -P /usr/share/uboot/rpi_arm64/u-boot.bin /boot/efi/rpi-u-boot.bin
mkdir -p /usr/lib/bootc-raspi-firmwares
cp -a /boot/efi/. /usr/lib/bootc-raspi-firmwares/
dnf remove -y bcm2711-firmware uboot-images-armv8
mkdir /usr/bin/bootupctl-orig
mv /usr/bin/bootupctl /usr/bin/bootupctl-orig/
EOF
copy bootupctl-shim /usr/bin/bootupctl
run chmod +x /usr/bin/bootupctl

# add containers
copy syncthing.container miniflux/* vaultwarden.container soju/systemd/* /usr/share/containers/systemd
copy soju/Containerfile /usr/share/containerfiles/soju-Containerfile
run systemctl enable podman-auto-update.timer

run dnf remove -y nano
run dnf install -y helix

run dnf clean all
run bootc container lint
