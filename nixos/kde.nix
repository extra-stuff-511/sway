{ config, lib, pkgs, ... }:

{
  # Display Mananger
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Desktop Environment
  hardware.graphics.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    baloo
    akonadi
    kdeplasma-addons
    kdepim-runtime
    kontact
    kmail
    akregator
    discover
    khelpcenter
    kinfocenter
    kate
    kwalletmanager
    kwallet
    plasma-systemmonitor
    krfb
    krdc
  ];
  

  # Packages
  environment.systemPackages = with pkgs; [
    git
    curl
    fastfetch
    htop
    neovim
    timeshift
    kdePackages.filelight
    elisa
    haruna
  ];

  # System Services
  services.power-profiles-daemon.enable = true;
  services.printing.enable = false;
  services.avahi.enable = false;
  services.flatpak.enable = false;
  programs.kdeconnect.enable = false;
  services.printing.browsed.enable = false;
  services.ipp-usb.enable = false;
  services.geoclue2.enable = false;
  
  # Environment Variables
}
