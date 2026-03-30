# Commands

Useful commands.

## Apply config

sudo nixos-rebuild switch --flake .#nixos

## Persist Noctalia config

nix run nixpkgs#noctalia-shell ipc call state all > ./modules/features/noctalia.json

## See generated niri config

less $(sed -nE 's/.*NIRI_CONFIG\s*(.*)/\1/p' "$(which niri)")
