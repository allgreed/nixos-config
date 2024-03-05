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
      # it's best this happens when I'm not using the network actively, aka sleeping - 5am seems like a best bet
      OnCalendar = "*-*-* 5:00:00";
      Unit = "daily-random-bytes.service";
      # TODO: persistent = true also is a good idea, since I want this to happen every day, especially when the craptop is off
      # TODO: waaaaait, can I just have a service without a seperate timer?
      # https://nixos.wiki/wiki/Systemd/Timers
      # TODO: waaaaait, can I just have a service without a seperate timer?
      # https://nixos.wiki/wiki/Systemd/Timers
    };
  };

  config.systemd.services.ogar-metric-reporter = {
    # TODO: lower service privilage -> to a user that can only write that one file, read ~/.task and read ~/notes
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      User = "allgreed";
    };
    # TODO: is the PATH thing an awfull hack? o.0
    script = ''
        export PATH=$PATH:/run/current-system/sw/bin
        cd ~/Desktop/ogar-metric-exporter
        nix-shell --command "make report"
    '';
  };
  config.systemd.timers.ogar-metric-reporter = {
    wantedBy = [ "timers.target" ];
    partOf = [ "ogar-metric-reporter.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "ogar-metric-reporter.service";
    };
  };

  config.systemd.services.tw-ical-feed-uploader = {
    # TODO: actually the processing & upload could happen in a pipe, so that there's no need for writing to disk
    # TODO: lower service privilage -> read ~/.task;
    # TODO: and actually -> this could run only and directly after a change is made to a task's sheduled or due attribute or a task with said attribute set
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      User = "allgreed";
    };
    # TODO: is the PATH thing an awfull hack? o.0
    script = ''
        export PATH=$PATH:/run/current-system/sw/bin
        cd ~/Desktop/tw-ical-feed
        nix-shell --command "make upload"
    '';
  };
  config.systemd.timers.tw-ical-feed-uploader = {
    wantedBy = [ "timers.target" ];
    partOf = [ "tw-ical-feed-uploader.service" ];
    timerConfig = {
      # TODO: did you see the comments above? ;p
      OnCalendar = "hourly";
      Unit = "tw-ical-feed-uploader.service";
    };
  };
}
