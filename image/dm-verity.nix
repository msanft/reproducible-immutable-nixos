{
  ...
}:
{
  # Mount rootfs at /(sysroot) and tmpfs-s where necessary for NixOS
  # activation to succeed.
  # TODO(msanft): This really, really needs better support upstream.
  fileSystems =
    let
      tmpfsConfig = {
        neededForBoot = true;
        fsType = "tmpfs";
      };
    in
    {
      "/" = {
        fsType = "erofs";
        options = [ "ro" ]; # so that systemd-remount-fs can work
        device = "/dev/mapper/root";
      };
    }
    // builtins.listToAttrs (
      builtins.map
        (path: {
          name = path;
          value = tmpfsConfig;
        })
        [
          "/var"
          "/etc"
          "/bin" # /bin/sh symlink needs to be created
          "/usr" # /usr/bin/env symlink needs to be created
          "/tmp"
        ]
    );

    boot.initrd.systemd.dmVerity.enable = true;
}
