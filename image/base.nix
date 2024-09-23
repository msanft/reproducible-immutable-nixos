{
  pkgs,
  ...
}:
{
  # We'll directly boot into the UKI, no bootloader needed.
  boot.loader.grub.enable = false;

  boot.initrd.systemd = {
    # Use systemd in the initrd rather than the default, script-based
    # initrd.
    enable = true;
    # Use systemd-networkd in the initrd.
    network.enable = true;
  };

  # Use systemd-resolved.
  services.resolved.enable = true;

  # Use systemd-networkd in the main system..
  systemd.network.enable = true;
  networking.useNetworkd = true;
  # ..disable networkmanager..
  networking.networkmanager.enable = false;
  # ..and the system DHCP.
  networking.useDHCP = false;

  boot.kernelParams = [
    # Get output on the serial console.
    "console=ttyS0"
  ];

  environment.systemPackages = with pkgs; [
    cryptsetup
  ];

  system = {
    # Disable in-place upgrades, we're immutable!
    switch.enable = false;
    stateVersion = "24.05";
  };
}
