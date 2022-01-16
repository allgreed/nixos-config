{ config, pkgs, callPackage, ... }: 
let
  nixpkgs = builtins.fetchGit {
    # 2021-08-24
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "253aecf69ed7595aaefabde779aa6449195bebb7";
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs nixos-unstable`
  };
  unstablePkgs = import nixpkgs { config = {}; };
in
{
  nixpkgs.overlays = [
  ];
    # TODO: split this
    environment.systemPackages = with pkgs; [
        python27
        (python38.withPackages(ps: with ps; [ 
          click
          ptpython 
          requests
          i3ipc
          tasklib
          subliminal
          grip
        ]))

        wally-cli

        cachix
        rnix-lsp
        bat
        tealdeer

        calibre
        et

        sox
        linuxPackages.usbip

        pv
        ntfs3g
        hledger
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

        spotify
        teams

        tree

        imagemagick

        pavucontrol

        evince
        vlc
        mpv
        enca # character encoding detecter and transformer
        gnome3.eog # TODO: drop in favour of feh?
        gimp

        arandr
        powertop

        #urxvt_font_size # TODO: how to make this work?

        graphviz

        unzip # TODO: vs unzipNLS?

        mkpasswd
        lastpass-cli

        unstablePkgs.rambox
        ferdi

        gnumake # build / script automation
        expect # interactive script automation utility
        git

        pirate-get
        deluge

        taskwarrior

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
    ];
}
