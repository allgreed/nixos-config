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
        #autorun = false; TODO: this needs some more work, because I have no idea how to manually start X under NixOS

        layout = "pl";
        xkbOptions = "ctrl:nocaps";

        desktopManager = {
            default = "none";
            xterm.enable = false;
        };

        windowManager.i3 = {
            enable = true;
            extraPackages = with pkgs; [
                feh
                dmenu
                i3lock
                i3blocks
           ];
        };
    };
}

