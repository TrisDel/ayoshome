# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

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
  networking.interfaces.enp2s0.ipv4.addresses = [ { address = "192.168.5.1"; prefixLength = 24; } ];

  # NAT 
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "enp2s0" ];
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp1s0";
  networking.nat.internalIPs = [ "192.168.5.0/24" ];

  # DARKSTAT
  systemd.services.darkstat = {
    enable = true;
    description = "darkstat for Ayos";
    serviceConfig = {
      Type = "forking";
      ExecStart = "/run/current-system/sw/bin/darkstat -i enp2s0 -l 192.168.5.0/24 --local-only";
      ExecStop = "pkill darkstat";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
  };
 
  # DHCPD, DNS
  services.kea.dhcp4.enable = true;
  services.kea.dhcp4.settings = {
    interfaces-config = {
      interfaces = [
        "enp2s0"
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

