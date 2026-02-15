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

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;

      # TODO: set this up
      autoPrune = {
        enable = true;
        dates = "monthly";
      };
    };
  };
  virtualisation.oci-containers.backend = "podman";

  boot = {
    # TODO: form an opinion, although /tmp that's actually persistent seems like fun
    #tmp.useTmpfs = true;

  loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    copyKernels = true;
    mirroredBoots = [
      { devices = [ "nodev"]; path = "/boot"; }
    ];
  };

    # for usbip
    extraModulePackages = with config.boot.kernelPackages; [ usbip ];
    kernelModules = [ "vhci-hcd" ];

    kernelParams = [
      "nohibernate"
      # TODO: test if it boots
      #"elevator=none"
  ];

  };

  hardware.pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      extraConfig = "unload-module module-role-cork"; # prevents Teams/whatnot from muting other streams
  };
  # TODO: use more pipewire?!
  services.pipewire.enable = false;
  # TODO: which is more fun? :D
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # udev rules for flashing / live-training
  hardware.keyboard.zsa.enable = true;

  # TODO: I don't think this works really :c
  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';

  # this is being tried out
  system.copySystemConfiguration = true;

  # TODO: group services entries I guess
  # doesn't it cause some weird merging issues?
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

  #hardware.sane.enable = true;  # scanning
  ## TODO: what is it? apparently it's needed for a USB scanner https://nixos.wiki/wiki/Scanners
  #services.ipp-usb.enable=true;
  #hardware.sane.extraBackends = [ pkgs.sane-airscan ];

  users = {
    mutableUsers = false;

    users.allgreed = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "audio"

          # printing & scanning
          "lpadmin"
          "lp"
          "scanner"

          "video"
          "dialout"
        ];
        initialHashedPassword = "$6$sEk83.F2VbsYW$iILuEeRZZE5aIh87UIze4R7g82JGavVkm3yURcI38Zka5M/djEClUEr0.PWklwdea0UrGKrNAx3B.BKh435Uu0"; # please change the password via local.nix ASAP
    };
    # TODO: change this to something I know and save it in a secured location
    # TODO: try mutiple hashing rounds
  };

  services.trezord.enable = true;

  # TODO: is this done?
  # https://github.com/NixOS/nixpkgs/pull/289680
  # TODO: how to update to this patch?
  #environment.systemPackages = with pkgs; [
  #  doas-sudo-shim
  #];
  security = {
    #sudo.enable = false;  # yes, it's a statement
    # apparently we can't have nice things, see if it's beeter with 24.05
    sudo.enable = true;
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
    apparmor = {
      enable = true;
    };
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
  system.stateVersion = "24.05";
}
