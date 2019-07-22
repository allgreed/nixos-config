{ config, pkgs, callPackage, ... }: 
{
    environment.systemPackages = with pkgs; [
        python27
        python3

        htop
        tmux # terminal multiplexer
        ranger # file exploler

        dotfiles

        direnv
        vimHugeX

        xorg.xmodmap
        xcape
        xclip
        scrot
        imagemagick

        rxvt_unicode

        unzip # TODO: vs unzipNLS?

        mkpasswd

        firefox

        gnumake # build / script automation
        expect # interactive script automation utility
        git
        ansible 

        jq # manipulate JSON

        # curl 
        # net-tools
        # openvpn
        # wireshark # packet sniffing / analyzing
        # wakeonlan
        # nmap
        # whois
        # arp-scan # arp discovery
    
        # pip ptpython # improved Python shell
        # pip pygments-style-solarized # colorscheme
        # pip pirate-get # command line for the pirate bay
    ];
}

