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
        ./networking.nix
        ./gui.nix
      ]
      ++ localConfiguration;

    fileSystems."/media/ramdisk" =
    {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "nosuid" "nodev" "noexec" "nodiratime" "size=5M" ];
    };

    sound.enable = true;
    hardware.pulseaudio.enable = true;

    time.timeZone = "Europe/Warsaw";
    # Select internationalisation properties.
    # i18n = {
    #   consoleFont = "Lat2-Terminus16";
    #   consoleKeyMap = "us";
    #   defaultLocale = "en_US.UTF-8";
    # };

    users.users.allgreed = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
    };


    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = "19.03"; # Did you read the comment?
}
