{
  pkgs,
  lib,
  platform,
  withDebug ? true,
  ...
}:
let
  # We write this placeholder into the command line and replace it with the real root hash
  # after the image is built.
  roothashPlaceholder = "61fe0f0c98eff2a595dd2f63a5e481a0a25387261fa9e34c37e3a4910edf32b8";
in
(pkgs.nixos (
  {
    modulesPath,
    ...
  }:
  {
    boot.kernelParams = [
      "roothash=${roothashPlaceholder}"
    ];

    imports = [
      ./base.nix
      ./image.nix
      ./dm-verity.nix
      "${modulesPath}/image/repart.nix"
      "${modulesPath}/system/boot/uki.nix"
      ./platform-specific/${platform}.nix
    ] ++ lib.optionals withDebug [ ./debug.nix ];
  }
)).image.overrideAttrs
  (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.jq ];
    # Replace the placeholder with the real root hash.
    # Only replace first occurrence, or integrity of erofs will be compromised.
    postInstall = ''
      realRoothash=$(${lib.getExe pkgs.jq} -r "[.[] | select(.roothash != null)] | .[0].roothash" $out/repart-output.json)
      sed -i "0,/${roothashPlaceholder}/ s/${roothashPlaceholder}/$realRoothash/" $out/${oldAttrs.pname}_${oldAttrs.version}.raw
    '';
  })
