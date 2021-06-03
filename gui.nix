{ config, pkgs, callPackage, ... }: 
{
    environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw  ???? --- what does this do?? xD

    fonts.fonts = with pkgs; [
        source-code-pro
        font-awesome-ttf
        # TODO: fix terminal fonts so that lsd can be used
    ];

    services.xserver = {
        enable = true;

        autorun = false;
        displayManager = {
          startx.enable = true;
          defaultSession = "none+i3";
        };

        layout = "pl";
        xkbOptions = "caps:ctrl_modifier, shift:both_capslock_cancel";

        desktopManager = {
            xterm.enable = false;
        };

        windowManager.i3 = {
            enable = true;
            extraPackages = with pkgs; [
                feh
                dmenu
                i3lock-color
                i3blocks
                networkmanager_dmenu
           ];
        };
    };

  # fix for Workrave not persisting settings
  services.dbus.packages = with pkgs; [ gnome3.dconf ];
}

