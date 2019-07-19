{ config, pkgs, ... }:
let
    localConfiguration = if builtins.pathExists ./local.nix
        then [ ./local.nix ]
        else [];
in
{
    imports = [ 
        ./hardware-configuration.nix
        ./gui.nix
      ]
      ++ localConfiguration;

    networking.networkmanager.enable = true;
    time.timeZone = "Europe/Warsaw";

    # Select internationalisation properties.
    # i18n = {
    #   consoleFont = "Lat2-Terminus16";
    #   consoleKeyMap = "us";
    #   defaultLocale = "en_US.UTF-8";
    # };

    environment.systemPackages = with pkgs; [
      direnv
      vim

      git

      dotfiles

      firefox
    ];

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];

    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    sound.enable = true;
    hardware.pulseaudio.enable = true;

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
