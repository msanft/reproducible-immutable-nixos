{
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "boot-uefi-qemu";

  runtimeInputs = with pkgs; [
    qemu
    swtpm
  ];

  text =
    let
      tpmOVMF = pkgs.OVMF.override { tpmSupport = true; };
    in
    ''
      tpmdir=$(mktemp -d)
      swtpm socket -d --tpmstate dir="$tpmdir" \
        --ctrl type=unixio,path="$tpmdir/swtpm-sock" \
        --tpm2 \
        --log level=20

      tmpFile=$(mktemp)
      cp "$1" "$tmpFile"
      qemu-system-x86_64 \
        -enable-kvm \
        -m 4G \
        -nographic \
        -drive if=pflash,format=raw,readonly=on,file=${tpmOVMF.firmware} \
        -drive if=pflash,format=raw,readonly=on,file=${tpmOVMF.variables} \
        -chardev socket,id=chrtpm,path="$tpmdir/swtpm-sock" \
        -tpmdev emulator,id=tpm0,chardev=chrtpm \
        -device tpm-tis,tpmdev=tpm0 \
        -drive "format=raw,file=$tmpFile"
    '';
}
