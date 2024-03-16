{ config, pkgs, callPackage, ... }: 
let
  #unfreeConfig = import ./pizza.nix;
  unfreeConfig = {
    allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      "rambox"

      "google-chrome"

      # my home printer drivers... maybe
      #"brgenml1lpr"

      # for zoom, although I'm not using Zoom as of lately
      #"zoom-us"
      #"zoom"
      #"faac"
    ];
  };

  # TODO: see if this is necessary after channel bump
  unstablePkgs = import (builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "b8697e57f10292a6165a20f03d2f42920dfaf973"; # 4-03-2024
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
  # TODO: do I have to pass pkgs here?
  # TODO: if "no" <- adjust all call sites
  }) { config = {} // (unfreeConfig); };

  # TODO: how to make sure this matches the python that's used in packages lower?
  subtitle-filter = with pkgs.python39Packages; buildPythonPackage rec {
    pname = "subtitle-filter";
    version = "1.4.7";
    src = builtins.fetchGit {
      url = "https://github.com/allgreed/filter-subs/";
      rev = "5180856aa2f2cc3cfa5f5574592b59055022cf8d";
    };
  };

  # TODO: actually use latest Rambox or switch to something else
  ramboxPkgs = import (builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "f2537a505d45c31fe5d9c27ea9829b6f4c4e6ac5"; # 27-06-2022 <- this works
  }) { config = {} // (unfreeConfig); };
in
{
  # TODO: ok, but how to export this to a seperate file -> see pizza.nix
  nixpkgs.config = {
    # TODO: get rid of this - figure out how to update to the latest stable or whatever !!!
    permittedInsecurePackages = [
      "nix-2.15.3"
    ];
  } // unfreeConfig;
  nixpkgs.overlays = [
    # https://github.com/NixOS/nixpkgs/issues/293038
    (final: prev: {
       grub2 = (import ./misc/specific-version.nix {}).grub2."2.06";
    })
  ];

    # TODO: split this
  environment.systemPackages = with pkgs; [
      #python27
      # TODO: just drop it?
      #(python39.withPackages(ps: with ps; [ 
        #click
        #ptpython 
        #requests
        #i3ipc
        #tasklib
        #typer

        #subtitle-filter
        ## those are actual packages as opposed to dependant libs
        ##subliminal
        ## TODO: fix this, probably just by bumping python version globally
        ## or just move to proper nixpkgs, instead of globally installed python - will this work? o.0
        ##python-pushover
        ## TODO: sad frog -> fix this!
      #]))

      wally-cli
      #smbclient
      # TODO: FIX IT!
      macchanger

      cachix
      rnix-lsp
      bat
      tealdeer

      appimage-run

      calibre
      et

      sox
      linuxPackages.usbip

      unstablePkgs.yt-dlp
      unstablePkgs.doas-sudo-shim

      pv
      ntfs3g
      unstablePkgs.hledger
      #hledger-iadd
      # TODO: fix broken!

      unstablePkgs.google-chrome

      htop
      tmux # terminal multiplexer
      ranger # file exploler

      minicom

      bc
      #manpages
      # TODO: fix it!!!

      dotfiles


      # parts of gui depend on it -> blocks
      acpi
      kubectl
      lm_sensors

      gitAndTools.hub
      gitAndTools.git-open

      direnv
      nix-direnv
      vimHugeX
      # TODO: get it back to stable one the version catches up
      unstablePkgs.neovim
      entr
      tmate

      tree

      imagemagick

      pavucontrol

      evince
      vlc
      mpv
      enca # character encoding detecter and transformer
      gnome3.eog # TODO: drop in favour of feh?

      gimp
      openscad
      freemind

      arandr
      powertop

      #urxvt_font_size # TODO: how to make this work?

      graphviz

      unzip # TODO: vs unzipNLS?

      mkpasswd
      lastpass-cli

      ramboxPkgs.rambox

      gnumake # build / script automation
      expect # interactive script automation utility
      git

      pirate-get
      deluge

      taskwarrior
      tasksh
      vit

      jq # manipulate JSON

      borgbackup

      dnsutils
      wavemon
      sshfs
      #dhcp
      # TODO: fix this!
      iftop
      traceroute
      nettools
      openvpn
      wireshark
      nmap
      whois
      arp-scan
      # wakeonlan

      gramps

      ffmpeg

      # I don't need it *right now*, but with all the interviews and other bullshit it sometimes come in handy
      # otherwise fuck them
      #zoom-us
  ];
}
