# Deferred m-boot NaVi file-backed Linux boot

## Intent

Later restore and validate NaVi: a Linux installation stored in a flat/raw virtual-disk container that can be booted natively through m-loader and used as the disk of a virtual machine.

## Why pending

The current m-boot phase is limited to GRUB recovery, multiboot, device inspection, ISO boot and chainloading. NaVi needs substantial Linux initramfs logic to locate and mount a root filesystem inside the host filesystem's virtual-disk container, and separate native and virtual boot testing.

## Scope

`m-boot`, future Linux initramfs integration and native/virtual boot validation. No implementation in the active recovery work unit.

## Evidence

Current `m-boot/loader/script/menu-default` includes `KUbuntu (NaVi)` and `Linux NaVi` GRUB loopback examples using `disk-flat.vmdk`; these are historical code evidence, not validation. Current active `rumiai-dev/handoff/m-boot-standalone.md` explicitly defers this work.
