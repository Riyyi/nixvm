{
  flake.nixosModules.git =
    { pkgs, ... }:
    {

      environment.systemPackages = with pkgs; [
        git
      ];

      programs.git = {
        enable = true;
        config = {
          user = {
            name = "Riyyi";
            email = "riyyi3@gmail.com";
          };
          core = {
            pager = "less -x 1,5";
          };
          init = {
            defaultBranch = "master";
          };
        };
      };

    };
}
