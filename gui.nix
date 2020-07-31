{ config, pkgs, callPackage, ... }: 
{
    environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw  ???? --- what does this do?? xD

    fonts.fonts = with pkgs; [
        source-code-pro
        font-awesome-ttf

        #noto-fonts
        #noto-fonts-cjk
        #noto-fonts-emoji
        #liberation_ttf
        #mplus-outline-fonts
        #dina-font
        #proggyfonts
    ];

    services.xserver = {
        enable = true;

        autorun = false;
        displayManager.startx.enable = true;

        layout = "pl";
        xkbOptions = "caps:ctrl_modifier, shift:both_capslock_cancel";

        desktopManager = {
            default = "none+i3";
            xterm.enable = false;
        };

        windowManager.i3 = {
            enable = true;
            extraPackages = with pkgs; [
                feh
                dmenu
                i3lock
                i3blocks
                networkmanager_dmenu
           ];
        };
    };

  # fix for Workrave not persisting settings
  services.dbus.packages = with pkgs; [ gnome3.dconf ];
}

