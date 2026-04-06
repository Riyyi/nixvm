{
  flake.nixosModules.greeter =
    { pkgs, ... }:
    {

      environment.systemPackages = with pkgs; [
        ly
      ];

      services.displayManager.ly = {
        enable = true;
        x11Support = false;
        settings = {
          default_input = "password";
          clear_password = true;

          animation = "matrix";
          animation_frame_delay = 1000;

          bigclock = "en";
          bigclock_12hr = true;

          show_tty = true;
          hide_version_string = true;

          ly_log = "/var/log/ly.log";
          session_log = ".local/state/ly-session.log";
        };
      };


    };
}
