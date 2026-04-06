# Commands

Useful commands.

## Bootstrap

nix-shell -p git
git clone "https://github.com/Riyyi/nixvm"
cd nixvm
sudo nixos-rebuild switch --option experimental-features 'nix-command flakes pipe-operators' --flake .#nixos

## Apply config

sudo nixos-rebuild switch --flake .#nixos

## Persist Noctalia config

nix run nixpkgs#noctalia-shell ipc call state all > ./modules/features/noctalia/noctalia.json

## See generated niri config

less $(sed -nE 's/.*NIRI_CONFIG\s*(.*)/\1/p' "$(which niri)")

## See activationScripts

less /run/current-system/activate
