{
  ...
}:
{
  # Login to root account by default.
  services.getty.autologinUser = "root";

  # Emergency Access
  boot.initrd.systemd.emergencyAccess = true;
  systemd.enableEmergencyMode = true;

  boot.kernelParams = [ "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1" ];
}
