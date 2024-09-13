{
  config,
  pkgs,
  ...
}:
{
  image.repart = {
    name = "image";
    version = "0.0.1";

    # This defines the actual partition layout.
    partitions = {
      # EFI System Partition, holds the UKI.
      "00-esp" = {
        contents = {
          "/".source = pkgs.runCommand "esp-contents" { } ''
            mkdir -p $out/EFI/BOOT
            cp ${config.system.build.uki}/${config.system.boot.loader.ukiFile} $out/EFI/BOOT/BOOTX64.EFI
          '';
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          SizeMinBytes = "64M";
          UUID = "null"; # Fix partition UUID for reproducibility.
        };
      };

      # Nix store.
      "10-root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Label = "root";
          Format = "erofs";
          Minimize = "best";
          Verity = "data";
          VerityMatchKey = "root";
          # We need to ensure that mountpoints are available.
          # Normally, NixOS activation would take care of doing so, but since
          # we're read-only, we need to do it ourselves.
          # TODO(msanft): This could be done more elegantly with CopyFiles and a skeleton tree in the vcs.
          MakeDirectories = "/bin /boot /dev /etc /home /lib /lib64 /mnt /nix /opt /proc /root /run /srv /sys /tmp /usr /var";
        };
      };

      # Verity tree for the Nix store.
      "20-root-verity" = {
        repartConfig = {
          Type = "root-verity";
          Label = "root-verity";
          Verity = "hash";
          VerityMatchKey = "root";
          Minimize = "best";
        };
      };
    };
  };
}
