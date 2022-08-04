{ config, pkgs, callPackage, ... }: 
{
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw  ???? --- what does this do?? xD

  fonts.fonts = with pkgs; [
    source-code-pro
    font-awesome-ttf
    # serif
    crimson # just nice
    ferrum  # more like fantasy or fancy wild west
    junicode # medival
    # snas
    f5_6 # round edges futuristic
    jost # just nice

    # TODO: fix terminal fonts so that lsd can be used
    # note: nerfdfonts don't help here
    # (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
  ];

  services.xserver = {
    enable = true;

    autorun = false;
    displayManager = {
      startx.enable = true;
      defaultSession = "none+i3";
    };

    layout = "pl";
    xkbOptions = "caps:ctrl_modifier";

    desktopManager = {
        xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        feh
        (dmenu.overrideAttrs (oldAttrs: rec {
          patches = [
            (fetchpatch {
              url = "https://tools.suckless.org/dmenu/patches/solarized/dmenu-solarized-light-5.0.diff";
              sha256 = "0dwzf8aj8lvfqggb1lb1ds0r021dppxayg9gkrvr3004pgc0zwnq";
            })
            (fetchpatch {
              url = "https://tools.suckless.org/dmenu/patches/xresources/dmenu-xresources-4.9.diff";
              sha256 = "0clczp17zwkxy1qhy0inqjplxpq4mgaf4vvfvn063hk733r4i7rn";
            })
            (fetchpatch {
              url = "https://tools.suckless.org/dmenu/patches/line-height/dmenu-lineheight-5.0.diff";
              sha256 = "16aqbyp3mg2cgnm8dysbdgcdhh3r6k2fsw1cxzrkka22hvi73paa";
            })
            (fetchpatch {
              url = "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-4.9.diff";
              sha256 = "000fkg4dcr2vrpd442f2v6ycmmxdml781ziblzx5rxvvyclsryfd";
            })
          ];
        }))
        i3lock-color
        i3blocks
        networkmanager_dmenu
        networkmanagerapplet
        dunst

        # TODO: move this to a `package` stanza
        xorg.xwininfo
        brightnessctl
        acpilight # this is needed for `xbacklight` - for reporting
        xorg.xev
        xorg.xmodmap
        xcape
        xclip
        escrotum
        scrot # for locking, because escrotum is too slow :c
        conky
        numlockx
        workrave
        redshift
        unclutter
        screenkey # displays pressed keys, cool for presentations
        rxvt_unicode
        pasystray
        parcellite
        ];
      };
  };

  # fix for Workrave not persisting settings
  services.dbus.packages = with pkgs; [ gnome3.dconf ];
}

