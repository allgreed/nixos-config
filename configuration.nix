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
    ./borg.nix
    ./utilities.nix
    # TODO: does this warrant own file?
    ./autojump.nix
    # TODO: guard this o.0?
    ./cachix.nix
    ]
    ++ localConfiguration;

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # TODO: reenable after bumping
      # Required for containers under podman-compose to be able to talk to each other.
      #defaultNetwork.settings.dns_enabled = true;

      # TODO: set this up
      #virtualisation.podman.autoPrune.dates = "monthly"
    };
  };
  virtualisation.oci-containers.backend = "podman";

  boot = {
    tmp.useTmpfs = true;
    loader.grub.enable = true;

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

    # TODO: try after upgrading the channel to something latest
    #binfmt.registrations.appimage = {
      #wrapInterpreterInShell = false;
      #interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      #recognitionType = "magic";
      #offset = 0;
      #mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      #magicOrExtension = ''\x7fELF....AI\x02'';
    #};
  };

  sound.enable = true;
  hardware.pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      extraConfig = "unload-module module-role-cork"; # prevents Teams/whatnot from muting other streams
  };

  # udev rules for flashing / live-training
  hardware.keyboard.zsa.enable = true;

  # TODO: I don't think this works really :c
  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';

  services.spotifyd.enable = true;

  services.tzupdate.enable = true;
  
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0=75;
      STOP_CHARGE_THRESH_BAT0=80;
      CPU_SCALING_GOVERNOR_ON_AC="schedutil";
      DEVICES_TO_DISABLE_ON_STARTUP="bluetooth";
    };
  };

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

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
      persistent = true;
    };
    settings.experimental-features = [ "nix-command" "flakes" ];
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
    sudo.enable = false;  # yes, it's a statement
    doas = {
      enable = true;
      extraRules = [
        {
          users = [ "allgreed" ];
          # TODO: is this *really* what I want?
          persist = true;
          keepEnv = true;
          # TODO: this is probably casuing ugly warnings on rebuild
          setEnv = [ "HOME=/home/allgreed" ];
        }
      ];
    };
  };
  # might still be required for some stuff
  # https://github.com/NixOS/nixpkgs/pull/289680
  environment.systemPackages = with pkgs; [
    doas-sudo-shim
  ];

  # TODO: hmmm? how usefulll is this?
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
  };

  # otherwise the logs will just pile up...
  services.journald.extraConfig = ''
    # 30 days on Sarah in 2023 was ~500M, double that should be plenty
    SystemMaxUse=1G
  '';
  # TODO: does the above account for a broken service just spamming logs? Can I throttle just that?

  # uncomment to cache all dependencies locally (might download crapload of stuff)
  #system.includeBuildDependencies = true;

  # TODO: https://github.com/wimpysworld/nix-config/commit/5ea9bba6e5d2f3fd4f99311a23a165e7253c0128
  #programs.nix-ld.enable = true;
  #programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  #];

  # Kto ma wiedzieć, ten wie
  system.stateVersion = "22.05";
}
