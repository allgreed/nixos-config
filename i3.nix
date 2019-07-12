{ config, pkgs, callPackage, ... }: 
{
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 

  services.xserver = {

    desktopManager = {
      default = "none";
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
	xorg.xmodmap
	feh
	xcape
        dmenu
        i3lock
        i3blocks
	source-code-pro
	rxvt_unicode
     ];
    };

  };
}

