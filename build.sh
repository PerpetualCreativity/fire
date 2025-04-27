#!/usr/bin/env fish

set image ghcr.io/perpetualcreativity/fire

podman build -t $image . --build-arg="vulcan_pubkey=$(cat ~/.ssh/id_ed25519.pub)"

if contains -- --push $argv
    podman push $image
end
