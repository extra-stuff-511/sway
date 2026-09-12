{ config, lib, pkgs, ... }:

{
  # Display manager
  services.displayManager.cosmic-greeter.enable = true;

  # Desktop Manager
  hardware.graphics.enable = true;
  services.desktopManager.cosmic.enable = true;
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-store
  ];

  # Packages
  environment.systemPackages = with pkgs; [
    git
    curl
    fastfetch
    htop
    neovim
    timeshift
  ];

  # Environment Variables
    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = "1";
}
