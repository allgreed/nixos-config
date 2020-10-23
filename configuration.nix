{ config, pkgs, ... }:
let
    localConfiguration = if builtins.pathExists ./local.nix
        then [ ./local.nix ]
        else [];
in
{
    imports = [ 
        ./hardware-configuration.nix
        ./pkg.nix
        ./pizza.nix
        ./networking.nix
        ./gui.nix
      ]
      ++ localConfiguration;

    fileSystems."/media/ramdisk" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "nosuid" "nodev" "noexec" "nodiratime" "size=5M" ];
    };

    virtualisation.docker.enable = true;

    boot.tmpOnTmpfs = true;

    sound.enable = true;
    hardware.pulseaudio = {
        enable = true;
        support32Bit = true;
    };

    time.timeZone = "Europe/Warsaw";

    i18n = {
        consoleUseXkbConfig = true;
        defaultLocale = "en_GB.UTF-8";
    };

    documentation.dev.enable = true;

    services.physlock = {
      enable = true;
      allowAnyUser = true;
    };

    # TODO: override nixos-help setting and don't display the help message, but keep everything else
    services.mingetty.helpLine = ''
      [1;32m[1;41mNo gods or kings.
          Only men.    [0m
    '';

    users = {
        mutableUsers = false;

        users.allgreed = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "docker" "audio" ];
            initialHashedPassword = "$6$sEk83.F2VbsYW$iILuEeRZZE5aIh87UIze4R7g82JGavVkm3yURcI38Zka5M/djEClUEr0.PWklwdea0UrGKrNAx3B.BKh435Uu0"; # please change the password via local.nix ASAP
        };
	# TODO: change this to something I know and save it in a secured location
        # TODO: try mutiple hashing rounds
    };

    security.sudo.enable = false;
    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [ "allgreed" ];
          persist = true;
          keepEnv = true;
          setEnv = [ "HOME=/home/allgreed" ];
        }
      ];
    };

    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = "19.03"; # Did you read the comment?
}
