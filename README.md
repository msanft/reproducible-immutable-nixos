# Building reproducible and immutable NixOS images

This is the accompanying repository for my [All Systems Go 2024 talk with the same name](https://www.youtube.com/watch?v=YAl27ciB6c8).

> [!IMPORTANT]
> This repository is not meant for direct consumption via this Flake. Outputs may and will be unstable. It is rather meant as
> a reference for how such images may look and be built like.

As of now, only images to be booted with QEMU are built, but I'm happy to take contributions for other platforms.

## What this repository wants to achieve

It should be a reference for how immutable NixOS configurations can be built, and how they can be packed into OS images reproducibly.
It is very unlikely that the exact configuration presented here can be used in any real-world scenario as is. It should rather be
considered a one-size-fits-most approach, and tweaked per use-case.

## How to Build

```sh
# Build the GPT disk image
nix build .#qemu-image
# Verify reproducibility
nix build .#qemu-image --keep-failed --rebuild
# Boot it in QEMU
nix run .#boot-uefi-qemu -- ./result/image_0.0.1.raw
```

## Features

- Measured boot with [UKI](https://github.com/uapi-group/specifications/blob/main/specs/unified_kernel_image.md)
- Read-only root partition, integrity-protected by [dm-verity](https://docs.kernel.org/admin-guide/device-mapper/verity.html)
    - Filesystem integrity is embedded into PCR values through kernel command line (`roothash=`)
    - System integrity is verifiable through TPM remote attestation
- Bootable image built with [systemd-repart](https://www.freedesktop.org/software/systemd/man/latest/systemd-repart.html)

## Credits

- [nix-store-veritysetup-generator](https://github.com/nikstur/nix-store-veritysetup-generator) by @nikstur
- [nixlet](https://github.com/petm5/nixlet) by @petm5
- [server-optimised-nixos](https://github.com/arianvp/server-optimised-nixos) by @arianvp
