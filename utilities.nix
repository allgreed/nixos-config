{ config, pkgs, ... }:
{
  config.systemd.services.daily-random-bytes = {
    # TODO: lower service privilage -> to a user that can only write that one file
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      User = "allgreed";
    };
    script = ''
        export PATH=$PATH:/run/current-system/sw/bin
        hexdump -vn16 -e'4/4 "%08X" 1 "\n"' /dev/urandom > /var/state/daily-random-bytes/data
        date --utc +%s > /var/state/daily-random-bytes/last
    '';
  };
  config.systemd.timers.daily-random-bytes = {
    wantedBy = [ "timers.target" ];
    partOf = [ "daily-random-bytes.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 5:00:00";
      Unit = "daily-random-bytes.service";
    };
  };
}
