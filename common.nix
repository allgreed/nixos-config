{ config, pkgs, callPackage, ... }: 
{
    environment.systemPackages = with pkgs; [
        python27
        ansible 
    # python3
    # python3-pip

        htop
    # tmux # terminal multiplexer
    # ranger # file exploler

    # unzip

    # make # build / script automation
    # expect # interactive script automation utility
    # jq # manipulate JSON


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

