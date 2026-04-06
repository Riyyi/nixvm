{

  flake.nixosModules.vmware =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        open-vm-tools
      ];

      virtualisation.vmware.guest.enable = true;

      system.activationScripts.vmware-share = ''
        mkdir -p /mnt/share
      '';

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
