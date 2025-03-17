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

  networking.hostName = "ayoshome"; # Define your hostname.
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
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # AYOS SPECIFIC

  # IP Forwarding
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
  };

  # LAN interface
  networking.interfaces.enp2s0.useDHCP = false;
  networking.interfaces.enp2s0.ipv4.addresses = [ { address = "192.168.5.1"; prefixLength = 24; } ];

  # NAT 
  #networking.firewall.enable = false;
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp1s0";
  networking.nat.internalIPs = [ "192.168.5.0/24" ];
 
  # DHCPD, DNS
  services.dnsmasq.enable = true;
  services.dnsmasq.settings = {
    interface = "enp2s0";
    dhcp-range = [ "192.168.5.32,192.168.5.250" ];
  };
 
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

