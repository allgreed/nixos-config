{ config, pkgs, callPackage, ... }: 
{
    environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw  ???? --- what does this do?? xD

    services.xserver = {
        enable = true;
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

