@ECHO OFF

SET ROOT=%~dp0
SET SCRIPT_DIR=%ROOT:~-1%

SET QEMU_VM_NAME="Mac OS X Leopard"
SET MAC_VERSION_MAJOR="10"
SET MAC_VERSION_MINOR="5"
SET MAC_RAM="2G"
SET MAC_CORES="2"
SET MAC_DVD="NONE"
SET MAC_HD="harddrives/Leopard.qcow2"
SET MAC_GRAPHICS="-vga qxl"
SET MAC_SPICE_PORT="50020"

#SET EFI_CODE_PATH="NONE"

SET BOOT_IMAGE="bootloader/OpenCore_QEMU.img"
#SET CPU_OPTS="vendor=GenuineIntel,kvm=on,+sse3,+sse4.1,+sse4.2"

"%SCRIPT_DIR%/boot_intel_mac.bat"


