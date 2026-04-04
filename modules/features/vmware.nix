{ self, inputs, ... }:
{

  flake.nixosModules.vmware =
    { pkgs, lib, ... }:
    {
      virtualisation.vmware.guest.enable = true;

      systemd.services.vmware-share = {
        description = "VMware Shared Directory";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.open-vm-tools}/bin/vmhgfs-fuse .host:/Share /mnt/share -o allow_other";
          RemainAfterExit = true;
        };
      };
    };

}
