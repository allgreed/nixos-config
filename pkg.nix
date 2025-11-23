{ pkgs, ... }: 
      # TODO: enable python xD
let
  #unfreeConfig = import ./pizza.nix;
  # TODO: use more pizza?
  unfreeConfig = {
    allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      "google-chrome"
      "beeper"
    ];
  };
  # TODO: how to make sure this matches the python that's used in packages lower?
  filter-subtitles = with pkgs.python312Packages; buildPythonApplication {
    pname = "subtitle-filter";
    version = "1.4.7";
    src = builtins.fetchGit {
      url = "https://github.com/allgreed/filter-subs/";
      rev = "5180856aa2f2cc3cfa5f5574592b59055022cf8d";
    };
  };

  # TODO: SEE USAGES VERY CAREFULLY!
  # https://github.com/NixOS/nixpkgs/pull/320798
  ramboxPkgs = import (builtins.fetchGit {
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-unstable";
    rev = "f2537a505d45c31fe5d9c27ea9829b6f4c4e6ac5"; # 27-06-2022 <- this works
  }) { config = {} // (unfreeConfig); };
  latestPkgs = import (builtins.fetchTree {
    type = "git";
    url = "https://github.com/nixos/nixpkgs/";
    rev = "117cc7f94e8072499b0a7aa4c52084fa4e11cc9b"; # 23-11-2025
    narHash = "sha256-+hBiJ+kG5IoffUOdlANKFflTT5nO3FrrR2CA3178Y5s=";
  }) { config = {} // (unfreeConfig); };
in
{
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  nixpkgs.config = {
  # TODO: ok, but how to export this to a seperate file -> see pizza.nix
  } // unfreeConfig;

  nixpkgs.overlays = [
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
    	  # TODO: fix this patch - hunk 4 has some problems!
          #(prev.fetchpatch {
          #  url = "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-5.3.diff";
          #  hash = "sha256-uPuuwgdH2v37eaefnbQ93ZTMvUBcl3LAjysfOEPD1Y8=";
          #})
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
  ];

  # taskwarrior config needs a stable path to point to, maaaaybe it'd be better handled by home-manager, but right now it's what it is ;)
  environment.etc.taskwarrior_share = {
    source = "${pkgs.taskwarrior}/share";
  };

  environment.systemPackages = with pkgs; [
      (python312.withPackages(ps: with ps; [ 
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
	subliminal
        # TODO: get rid of this once the CLI is implemented
        pushover-complete
        # https://github.com/allgreed/dotfiles/commit/b3e97d06fe58223602925be510b6f3c255cdf871
        # TODO: wait for commandline or make a PR
      ]))
      pyright
      # TODO: this might require unstable?
      ruff-lsp

      # testing!
      delta

      filter-subtitles
      # TODO: try this instead of having it packaged with system python?
      #python312Packages.subliminal

      wally-cli
      macchanger

      cachix
      nil

      bat
      tealdeer

      calibre
      et

      # for sending messages fix
      latestPkgs.tg
      # TODO: bump latestPkgs, see if it fares better
      #latestPkgs.beeper

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

      lsix
      evince
      vlc
      mpv
      enca # character encoding detecter and transformer
      gnome.eog # TODO: drop in favour of feh?

      gimp
      # xsane GIMP is weird... it's way better to simple-scan + then process in GIMP
      simple-scan
      pdftk

      openscad
      freemind

      arandr
      powertop

      #urxvt_font_size # TODO: how to make this work?

      graphviz

      unzip # TODO: vs unzipNLS?

      mkpasswd
      lastpass-cli

      gnumake # build / script automation
      git

      pirate-get
      deluge

      taskwarrior2
      # TODO: migrate to taskwarrior3 after they handle the perfomance issues
      # https://github.com/GothenburgBitFactory/taskwarrior/issues/3329
      #taskwarrior3
      tasksh

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

      units

      # TODO: update system then delete this line
      #latestPkgs.ghostty # need Ghostty 1.2 for systemd units
      # systemctl enable --user app-com.mitchellh.ghostty.service <- this works with the new package
      ghostty # doing the upgrade this way breaks OpenGL context

      gramps

      ffmpeg
      dos2unix

      ncdu
      # baobab equivalent

      # I don't need it *right now*, but with all the interviews and other bullshit it sometimes come in handy
      # otherwise fuck them
      #zoom-us
  ];
}
