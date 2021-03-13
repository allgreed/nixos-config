{ config, pkgs, callPackage, ... }: 
{
    # TODO: split this
    environment.systemPackages = with pkgs; [
        python27
        (python38.withPackages(ps: with ps; [ 
          click
          ptpython 
          requests
          i3ipc
          subliminal
          grip
        ]))

        calibre
        et

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
        vimHugeX
        hexcurse
        entr
        tmate

        xorg.xwininfo

        spotify
        teams

        tree

        # TODO: does this belong to gui?
        acpilight
        xorg.xev
        xorg.xmodmap
        xcape
        xclip
        escrotum
        conky
        imagemagick
        numlockx

        pavucontrol

        evince
        vlc
        mpv
        enca # character encoding detecter and transformer
        gnome3.eog # TODO: drop in favour of feh?
        gimp

        workrave

        redshift
        unclutter

        arandr
        powertop

        screenkey # displays pressed keys, cool for presentations

        rxvt_unicode
        #urxvt_font_size # TODO: how to make this work?

        graphviz

        unzip # TODO: vs unzipNLS?

        mkpasswd
        lastpass-cli

        firefox
        rambox

        gnumake # build / script automation
        expect # interactive script automation utility
        git

        pirate-get
        deluge

        jq # manipulate JSON

        dnsutils
        wavemon
        sshfs
        dhcp
        iftop
        traceroute
        # net-tools
        # openvpn
        # wireshark # packet sniffing / analyzing
        # wakeonlan
        # nmap
        # whois
        # arp-scan # arp discovery
    
        # pip pygments-style-solarized # colorscheme
        # pip pirate-get # command line for the pirate bay
    ];
}
