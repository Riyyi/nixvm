# Commands

Useful commands.

## Apply config

sudo nixos-rebuild switch --flake .#nixos

## Persist Noctalia config

nix run nixpkgs#noctalia-shell ipc call state all > ./modules/features/noctalia.json
