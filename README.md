# my fedora bootc config

**TODO**: setup restart policies


This is for my Raspberry Pi 4. To install, build the Containerfile in this repo and then [install](#installing) the resulting image. 

Things this bootable container has:
- Fedora 41 (might change soon)
- Tailscale layered on
- Containers:
  - Syncthing
  - Vaultwarden
  - Soju (builds on boot if needed)
  - Miniflux (pod of Miniflux and Postgres)

## installing

I recommend using Podman Desktop with the Bootable Containers extension for building the container and the bootc images. Instead of building, you can also install ghcr.io/PerpetualCreativity/fire-rpi directly, but I do not recommend this if you are not me since it will automatically update every time I push to the registry :) (see `.github/workflows/build.yml`)

Notes:
- The Containerfile expects a `vulcan_pubkey` build argument, which will become the authorized ssh public key for the user `vulcan`.
- I've been using ext4; if I experiment with others later I will report here. bootc-image-builder supports XFS, ext4, and btrfs for root.
- Once you create the images, since Raspberry Pi Imager only accepts `.raw.xz` (and not `.raw`, for some reason) you may want to `xz -T0 -0 disk.raw`.
- After you boot, you will need to resize the main partition (AFAICT the default size is 10G).
- You'll also need to set a password for `vulcan`, the default is "temporary".

## tips

[podlet](https://github.com/containers/podlet) can generate quadlets ([podman-systemd.unit](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) files) from running containers/pods.
For services that are not easy to set up, I've found it's easier to create the containers/pods locally and then use podlet to generate a (starting point for) the quadlets. Note that you need `[Install] WantedBy=default.target`; podlet will omit this but it is necessary on bootc systems.

