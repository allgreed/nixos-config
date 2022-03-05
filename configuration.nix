{ config, pkgs, ... }:
let
  localConfiguration = if builtins.pathExists ./local.nix
    then [ ./local.nix ]
    else [];
  nonFreeConfiguration = if builtins.pathExists ./pizza.nix
    then [ ./pizza.nix ]
    else [];
in
{
  imports = [ 
    ./hardware-configuration.nix
    ./pkg.nix
    ./pizza.nix
    ./networking.nix
    ./gui.nix
    ./borg.nix
    # TODO: guard this o.0?
    ./cachix.nix
    ]
    ++ nonFreeConfiguration
    ++ localConfiguration;

  virtualisation.docker.enable = true;

  boot = {
    tmpOnTmpfs = true;
    loader.grub.enable = true;
    loader.grub.version = 2;

    loader.grub.zfsSupport = true;
    # TODO: how much of this is redundant with zfsSupport to true?
    # ZFS required, but generally won't hurt
    supportedFilesystems = [ "zfs" ];
    loader.grub.copyKernels = true;
    # ???
    initrd.supportedFilesystems = [ "zfs" ];

    # for usbip
    extraModulePackages = with config.boot.kernelPackages; [ usbip ];
    kernelModules = [ "vhci-hcd" ];
  };

  sound.enable = true;
  hardware.pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      extraConfig = "unload-module module-role-cork"; # prevents Teams/whatnot from muting other streams
  };
  services.spotifyd.enable = true;

  services.tzupdate.enable = true;
  
  services.tlp.enable = true;

  console.useXkbConfig = true;
  i18n = {
      defaultLocale = "en_GB.UTF-8";
  };

  documentation.dev.enable = true;

  services.physlock = {
    enable = true;
    allowAnyUser = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      #brlaser
      #brgenml1lpr
      #brgenml1cupswrapper
      #cups-brother-hl1210w
    ];
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
      frequent = 4;
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 0;
    };
  };

  # for nix-direnv
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  nix.gc = {
    automatic = true;
    dates = "monthly";
    persistent = true;
  };

  # TODO: override nixos-help setting and don't display the help message, but keep everything else
  services.getty.helpLine = ''
    [1;32m[1;41mNo gods or kings.
        Only men.    [0m
  '';

  users = {
    mutableUsers = false;

    users.allgreed = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
          "audio"
          "lpadmin"
          "video"
          "dialout"
        ];
        initialHashedPassword = "$6$sEk83.F2VbsYW$iILuEeRZZE5aIh87UIze4R7g82JGavVkm3yURcI38Zka5M/djEClUEr0.PWklwdea0UrGKrNAx3B.BKh435Uu0"; # please change the password via local.nix ASAP
    };
    # TODO: change this to something I know and save it in a secured location
    # TODO: try mutiple hashing rounds
  };

  services.trezord.enable = true;

  security = {
    sudo.enable = false;
    doas = {
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
  };
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
