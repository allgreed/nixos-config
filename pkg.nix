{ pkgs, ... }: 
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

      "hubstaff"
    ];
  };
  # TODO: how to make sure this matches the python that's used in packages lower?
  filter-subtitles = with pkgs.python39Packages; buildPythonApplication {
    pname = "subtitle-filter";
    version = "1.4.7";
    src = builtins.fetchGit {
      url = "https://github.com/allgreed/filter-subs/";
      rev = "5180856aa2f2cc3cfa5f5574592b59055022cf8d";
    };
  };

  # TODO: actually use latest Rambox or switch to something else
  # TODO: SEE USAGES VERY CAREFULLY!
  ramboxPkgs = import (builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "f2537a505d45c31fe5d9c27ea9829b6f4c4e6ac5"; # 27-06-2022 <- this works
  }) { config = {} // (unfreeConfig); };
in
{
  nixpkgs.config = {
  # TODO: ok, but how to export this to a seperate file -> see pizza.nix
  } // unfreeConfig;

  nixpkgs.overlays = [
    # https://github.com/NixOS/nixpkgs/issues/293038
    (final: prev: {
      # TODO: actually get this grub from a channel or something
      grub2 = (import ./misc/specific-version.nix {}).grub2."2.06";
    })
    (final: prev: {
      dmenu = prev.dmenu.overrideAttrs (oldAttrs: {
        patches = [
          (prev.fetchpatch {
            url = "https://tools.suckless.org/dmenu/patches/line-height/dmenu-lineheight-5.2.diff";
            hash = "sha256-QdY2T/hvFuQb4NAK7yfBgBrz7Ii7O7QmUv0BvVOdf00=";
          })
          (prev.fetchpatch {
            url = "https://tools.suckless.org/dmenu/patches/solarized/dmenu-solarized-light-5.0.diff";
            hash = "sha256-2PIP2LsEgJF3ni89r/q9LQiQgW5h0bDew25TJBVynzc=";
          })
          (prev.fetchpatch {
            url = "https://tools.suckless.org/dmenu/patches/xresources/dmenu-xresources-4.9.diff";
            hash = "sha256-Np9I8hhnwmGA3W5v4tSrBN9Or8Q2Ag9x8H3yf8L9jDI=";
          })
          (prev.fetchpatch {
            url = "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-4.9.diff";
            hash = "sha256-zfmsKfN791z6pyv+gA6trdfKvNnCCULazVtk1sibDgA=";
          })
        ];
      });
    })
    (final: prev: {
      # Fixes a problem that attempt to access /nix/store/.../var/lock .
      # Without this, the scanner is not detected.
      # see: https://github.com/NixOS/nixpkgs/issues/273280
      sane-backends = prev.sane-backends.overrideAttrs
        ({ configureFlags ? [ ], ... }: {
          configureFlags = configureFlags ++ [ "--disable-locking" ];
        });
    })
    # TODO: let them know
    # TODO: make Github issue and link it here
    # TODO: clean it up
    # TODO: upstream sensibly
    (final: prev: 
    let
      v = "1.6.23-5c646160";
    in
    {
      hubstaff = prev.hubstaff.overrideAttrs ({
        version = v;
        # the last section is a HACK HACK HACK
        # so the installPhase removes this directories, which are apparently not present in the lastest thingy
        # but it errors, since it doesn't have the -f flag
        unpackCmd = prev.hubstaff.unpackCmd + ''
          mkdir data/x86
          mkdir -p data/x86_64/lib64
        '';
        # TODO: figure out if I can at least pin the hash and just make the local file a mirror
        # this is another HACK
        # I cannot get the sources to play nicely with nix so I've just downloaded the latest version and keep it in my Downloads folder. Super*not*reproducible
        src = /home/allgreed/Downloads/Hubstaff-1.6.23-5c646160.sh;
        #src = builtins.fetchurl {
          #url = "https://hubstaff-production.s3.amazonaws.com/downloads/HubstaffClient/Builds/Release/${v}/Hubstaff-${v}.sh";
          #sha256 = "";
        #};
      });
    })
  ];

  # taskwarrior config needs a stable path to point to, maaaaybe it'd be better handled by home-manager, but right not it's what it is ;)
  environment.etc.taskwarrior_share = {
    source = "${pkgs.taskwarrior}/share";
  };

  environment.systemPackages = with pkgs; [
      hubstaff
      (python311.withPackages(ps: with ps; [ 
        ptpython  # my repl shell

        # I sometimes like to prototype and just want this to be there
        requests

        # global dependencies, shouldn't be here really...
        tasklib
        click
        i3ipc
        typer
        pexpect

        # those are "end-user" level actual packages
        # TODO: get rid of this once the CLI is implemented
        pushover-complete
        # https://github.com/allgreed/dotfiles/commit/b3e97d06fe58223602925be510b6f3c255cdf871
        # TODO: wait for commandline or make a PR
      ]))
      pyright
      # TODO: this might require unstable?
      ruff-lsp

      filter-subtitles
      (import (builtins.fetchGit {
        url = "https://github.com/nixos/nixpkgs/";
        ref = "refs/heads/nixos-unstable";
        rev = "69dfa612cc27b3495b766239dec31facb1df66b9"; # random commit the should be working
      }) { config = {} // (unfreeConfig); }).python311Packages.subliminal
      # https://github.com/NixOS/nixpkgs/blob/a1d99c033b84177048d9380eb37aa6057f5f451a/pkgs/development/python-modules/subliminal/default.nix#L98

      wally-cli
      #smbclient
      # TODO: FIX IT!
      macchanger

      cachix
      nil

      bat
      tealdeer

      appimage-run

      calibre
      et

      sox
      linuxPackages.usbip

      yt-dlp

      pv
      ntfs3g
      hledger
      ramboxPkgs.hledger-iadd
      # TODO: actually drop the ramboxPkgs, however there was a broken package, I'm like 3 minor behind

      google-chrome

      htop
      tmux # terminal multiplexer
      ranger # file exploler

      minicom

      bc
      man-pages
      man-pages-posix

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
      neovim
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
      # xsane GIMP is weird... it's way better to simple-scan + then process in GIMP
      simple-scan

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
      # here was 'dhcp' - https://github.com/NixOS/nixpkgs/issues/215571
      # TODO: learn enough networking fu to fix issues without dhclient restart xD
      # TODO: remove 'dhcprc'
      iftop
      traceroute
      nettools
      openvpn
      wireshark
      nmap
      whois
      arp-scan
      # wakeonlan
      # TODO: why is this commented out? o.0

      gramps

      ffmpeg

      # I don't need it *right now*, but with all the interviews and other bullshit it sometimes come in handy
      # otherwise fuck them
      #zoom-us
  ];
}
