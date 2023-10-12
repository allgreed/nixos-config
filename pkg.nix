{ config, pkgs, callPackage, ... }: 
let
  nixpkgs = builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    #rev = "f2537a505d45c31fe5d9c27ea9829b6f4c4e6ac5"; # 27-06-2022 <- this works
    rev = "81e8f48ebdecf07aab321182011b067aafc78896"; # 6-10-2023
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
  };
  # TODO: see if this is necessary after channel bump
  unstablePkgs = import nixpkgs { config = {
    allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      "rambox"
    ];
  }; };
  # TODO: how to make sure this matches the python that's used in packages lower?
  subtitle-filter = with pkgs.python39Packages; buildPythonPackage rec {
    pname = "subtitle-filter";
    version = "1.4.7";
    src = builtins.fetchGit {
      url = "https://github.com/allgreed/filter-subs/";
      rev = "9ff0efd9299b714381baba1689f0d0db643c7955";
    };
  };
  # TODO: actually use latest Rambox or switch to something else
  ramboxPkgs = import (builtins.fetchGit {
      url = "https://github.com/nixos/nixpkgs/";
      ref = "refs/heads/nixos-unstable";
      rev = "f2537a505d45c31fe5d9c27ea9829b6f4c4e6ac5"; # 27-06-2022 <- this works
    }) { config = {
      allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
        "rambox"
      ];
    }; 
  };
in
{
  nixpkgs.overlays = [
  ];
    # TODO: split this
    environment.systemPackages = with pkgs; [
        python27
        (python39.withPackages(ps: with ps; [ 
          click
          ptpython 
          requests
          i3ipc
          tasklib
          typer

          # those are actual packages as opposed to dependant libs
          subtitle-filter
          subliminal
          python-pushover
        ]))

        wally-cli
        smbclient
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

        pv
        ntfs3g
        unstablePkgs.hledger
        hledger-iadd

        google-chrome

        htop
        tmux # terminal multiplexer
        ranger # file exploler

        minicom

        bc
        manpages

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
        ferdi

        gnumake # build / script automation
        expect # interactive script automation utility
        git

        pirate-get
        deluge

        taskwarrior
        tasksh

        jq # manipulate JSON

        zoom-us

        borgbackup

        dnsutils
        wavemon
        sshfs
        dhcp
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
    ];
}
