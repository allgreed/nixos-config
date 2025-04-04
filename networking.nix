{ config, pkgs, callPackage, ... }: 
{
  networking.networkmanager = {
    enable = true;
    # comment the line below to enable some of the captive portal-based networking
    # TODO: make it werk
    #dns = "dnsmasq";

    wifi.scanRandMacAddress = false;
  };

  services.dnsmasq = {
    # TODO: make it werk
    #enable = true;

    settings.servers = [
      "/lan/192.168.69.1"
      # TODO: inform me if the query had to be resolved by backup and actually enable backup
      #"194.36.144.87"
      #"91.217.137.37"
      #"94.247.43.254"

      # backup
      "1.1.1.1"
      "8.8.8.8"
    ];

    resolveLocalQueries = true;
  };

  networking.firewall.allowedTCPPorts = [ 1313 ];
  # to check out Hugo server on other devices in the same network
  # TODO: what are the samba ports? how to enable them temporarly?
  #networking.firewall.enable = false;

  programs.captive-browser = {
    enable = true;
    # TODO: this isn't terribly portable
    interface = "wlp3s0";
  };
}
