{ config, lib, pkgs, ... }:

let
  perlEnv = pkgs.perl.withPackages (p: with p; [
    JSON
    # Add any other Perl modules you need here
  ]);
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ayos"; # Define your hostname.
  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.supayos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    tmux
    tcpdump
    nmap
    dnsutils
    sqlite
    darkstat
    vnstat
    kea
    lighttpd
    nodejs_22
    pm2
    perlEnv # Include the Perl environment with the specified modules
    websocketd
    sysstat
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Web server
  services.lighttpd.enable = true;
  services.lighttpd.document-root = "/ayos/www";

  # AYOS SPECIFIC

  # IP Forwarding
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  # LAN interface
  networking.interfaces.enp2s0.useDHCP = false;
  networking.bridges = {
    "br0" = {
      interfaces = [ "enp2s0" ];
    };
  };
  networking.interfaces.br0.ipv4.addresses = [ { address = "192.168.5.1"; prefixLength = 24; } ];

  # NAT
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "enp2s0" "br0" ];
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp1s0";
  networking.nat.internalIPs = [ "192.168.5.0/24" ];

  # DARKSTAT
  systemd.services.darkstat = {
    enable = true;
    description = "darkstat for Ayos";
    serviceConfig = {
      Type = "forking";
      ExecStart = "/run/current-system/sw/bin/darkstat -i br0 -l 192.168.5.0/24 --local-only";
      ExecStop = "pkill darkstat";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # VNSTATD
  systemd.services.vnstatd = {
    enable = true;
    description = "vnstatd for Ayos";
    serviceConfig = {
      Type = "forking";
      ExecStart = "/run/current-system/sw/bin/vnstatd -d";
      ExecStop = "pkill vnstatd";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # DHCPD, DNS
  services.kea.dhcp4.enable = true;
  services.kea.dhcp4.settings = {
    interfaces-config = {
      interfaces = [
        "br0"
      ];
    };
    lease-database = {
      name = "/var/lib/kea/dhcp4.leases";
      persist = true;
      type = "memfile";
    };
    rebind-timer = 2000;
    renew-timer = 1000;
    option-data = [ {
      name = "domain-name-servers";
      data = "192.168.5.1";
    } ];
    subnet4 = [
      {
        id = 1;
        pools = [
          {
            pool = "192.168.5.32 - 192.168.5.240";
          }
        ];
        subnet = "192.168.5.0/24";
        option-data = [ {
          name = "routers";
          data = "192.168.5.1";
          }
          {
          name = "domain-search";
          data = "lan";
        } ];
      }
    ];
    valid-lifetime = 4000;
  };

  networking.hosts = {
    "192.168.5.1" = [ "ayos.lan" "ayos" ];
  };
  networking.stevenblack.enable = true;
  services.dnsmasq.enable = true;
  services.dnsmasq.settings = {
    listen-address = "127.0.0.1,192.168.5.1";
  };
  services.resolved.domains = [ "lan" ];

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
