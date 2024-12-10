@ECHO OFF

IF "%MAC_HD%"=="" (
    echo "No Mac config loaded detected. First, load one with:"
    echo "source <config file> or . <config file>."
    echo ""

    EXIT /B 1
)

echo "Config for %QEMU_VM_NAME% loaded."
echo ""




REM ==========================================================================
REM DO NOT TOUCH ANYTHING BELOW THIS POINT UNLESS YOU KNOW WHAT ARE YOU DOING.
REM
REM You can customice many things exporting the corresponding variables
REM before executing this script. Then, your values will be used instead
REM default ones.
REM ==========================================================================

SET ROOT=%~dp0
SET SCRIPT_DIR=%ROOT:~-1%


REM ------ ADVANCED CONFIG AREA ---------

IF NOT "%CPU_OPTS%" == "" (
    SET CPU_EXTRA_OPTS=%CPU_OPTS%
)

SET CPU_OPTS="vendor=GenuineIntel,kvm=on,"

IF NOT "%CPU_EXTRA_OPTS%" == "" (
    SET CPU_OPTS=%CPU_OPTS%%CPU_EXTRA_OPTS%
) ELSE (
    SET CPU_OPTS=%CPU_OPTS%"+sse3,+sse4.1,+sse4.2"
)

IF "%AUDIO_DEVICE%" == "" (
    SET AUDIO_DEVICE="ich9-intel-hda"
)

IF "%DISK_CONTROLLER%" == "" (
    SET DISK_CONTROLLER="ich9-ahci"
)

IF "%MAC_NETWORK_MAC%" == "" (
    SET MAC_NETWORK_MAC="52:54:00:c9:18:27"
)

IF "%BOOT_DRIVE_BUS%" == "" (
    SET BOOT_DRIVE_BUS="DISK.1"
)

IF "%CD_DRIVE_BUS%" == "" (
    SET CD_DRIVE_BUS="DISK.2"
)

IF "%HD1_DRIVE_BUS%" == "" (
    SET HD1_DRIVE_BUS="DISK.3"
)

IF "%HD2_DRIVE_BUS%" == "" (
    SET HD2_DRIVE_BUS="DISK.4"
)

IF "%HD3_DRIVE_BUS%" == "" (
    SET HD3_DRIVE_BUS="DISK.5"
)

IF "%HD4_DRIVE_BUS%" == "" (
    SET HD4_DRIVE_BUS="DISK.6"
)

IF NOT "%EFI_CODE_PATH%" == "NONE" AND IF "%EFI_CODE_PATH%" == "" (
    SET EFI_CODE_PATH="%SCRIPT_DIR%/EFI/OVMF_CODE.fd"
    SET EFI_VARS_PATH="%SCRIPT_DIR%/EFI/OVMF_VARS.fd"
)

IF "%BOOT_IMAGE%" == "" (
    SET BOOT_IMAGE="%SCRIPT_DIR%/bootloader/OpenCore.img"
)

IF "%BOOTLOADER_DEVICE%" == "" (
    SET BOOT_IMAGE_EXT=%BOOT_IMAGE:~-4%

    IF "%BOOT_IMAGE_EXT%" == "qcow2" (
        REM Boot image format
        SET BIF="qcow2"

    ) ELSE (
        SET BIF="raw"
    )

    SET BOOTLOADER_DEVICE=ide-hd,bus=%BOOT_DRIVE_BUS%,drive=Bootloader
    SET BOOTLOADER_DRIVE=if=none,format=${BIF},media=disk,id=Bootloader
    SET BOOTLOADER_DRIVE=%BOOTLOADER_DRIVE%,file=%BOOT_IMAGE%
)


REM TODO

if ! [ "$MAC_DVD" == "NONE" ] && [ "$CD_DEVICE" == "" ];
then
    CD_DEVICE="ide-cd,bus=${CD_DRIVE_BUS},drive=DVD-RW"
    CD_DRIVE="if=none,format=raw,readonly=on,media=cdrom,id=DVD-RW"
    CD_DRIVE+=",file=${MAC_DVD}"
fi

if ! [ "$MAC_HD" == "" ];
then
    if [[ $MAC_HD == *.qcow2 ]];
    then
        # HD image format
        HIF="qcow2"
    else
        HIF="raw"
    fi

    HD1_DEVICE="ide-hd,bus=${HD1_DRIVE_BUS},drive=HardDrive"
    HD1_DRIVE="if=none,format=${HIF},media=disk,id=HardDrive,file=${MAC_HD}"
fi

if ! [ "$MAC_HD_2" == "" ];
then
    if [[ $MAC_HD_2 == *.qcow2 ]];
    then
        # HD image format
        HIF="qcow2"
    else
        HIF="raw"
    fi

    HD2_DEVICE="ide-hd,bus=${HD2_DRIVE_BUS},drive=HD2"
    HD2_DRIVE="if=none,format=${HIF},media=disk,id=HD2,file=${MAC_HD_2}"
fi

if ! [ "$MAC_HD_3" == "" ];
then
    if [[ $MAC_HD_3 == *.qcow2 ]];
    then
        # HD image format
        HIF="qcow2"
    else
        HIF="raw"
    fi

    HD3_DEVICE="ide-hd,bus=${HD3_DRIVE_BUS},drive=HD3"
    HD3_DRIVE="if=none,format=${HIF},media=disk,id=HD3,file=${MAC_HD_3}"
fi

if ! [ "$MAC_HD_4" == "" ];
then
    if [[ $MAC_HD_4 == *.qcow2 ]];
    then
        HIF="qcow2"
    else
        HIF="raw"
    fi

    HD4_DEVICE="ide-hd,bus=${HD4_DRIVE_BUS},drive=HD4"
    HD4_DRIVE="if=none,format=${HIF},media=disk,id=HD4,file=${MAC_HD_4}"
fi

# -------------------------------------




SET OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"

SET QEMU="C:\Apps\QEMU\qemu-system-x86_64"
SET QEMU_OPTS=""


IF NOT "%QEMU_VM_NAME%" == "" (
    SET QEMU_OPTS=%QEMU_OPTS% -name "%QEMU_VM_NAME%"
)

SET QEMU_OPTS=%QEMU_OPTS% -enable-kvm
SET QEMU_OPTS=%QEMU_OPTS% -m %MAC_RAM%
SET QEMU_OPTS=%QEMU_OPTS% -machine q35,accel=kvm
SET QEMU_OPTS=%QEMU_OPTS% -smp 4,cores=%MAC_CORES%
SET QEMU_OPTS=%QEMU_OPTS% -cpu Penryn,%CPU_OPTS%
SET QEMU_OPTS=%QEMU_OPTS% -device isa-applesmc,osk=%OSK%
SET QEMU_OPTS=%QEMU_OPTS% -smbios type=2

IF NOT "%EFI_CODE_PATH%" == "NONE" (
    SET QEMU_OPTS=%QEMU_OPTS% -drive if=pflash,format=raw,readonly=on
    SET QEMU_OPTS=%QEMU_OPTS%,file=%EFI_CODE_PATH%
    
    SET QEMU_OPTS=%QEMU_OPTS%-drive if=pflash,format=raw
    SET QEMU_OPTS=%QEMU_OPTS%,file=%EFI_VARS_PATH%
)

IF NOT "%MAC_GRAPHICS%" == "" (
    SET QEMU_OPTS=%QEMU_OPTS% %MAC_GRAPHICS%
) ELSE (
    SET QEMU_OPTS=%QEMU_OPTS% -vga qxl
)

IF NOT "%HEADLESS%" == "1" (
    SET QEMU_OPTS=%QEMU_OPTS% -display gtk
) ELSE (
    SET QEMU_OPTS=%QEMU_OPTS% -display none
)

IF NOT "%MAC_SPICE_PORT%" == "" (
    SET QEMU_OPTS=%QEMU_OPTS% -spice port=%MAC_SPICE_PORT%,addr=0.0.0.0
    SET QEMU_OPTS=%QEMU_OPTS% ,disable-ticketing=on
)

SET QEMU_OPTS=%QEMU_OPTS% -device %AUDIO_DEVICE%
SET QEMU_OPTS=%QEMU_OPTS% -device hda-output
SET QEMU_OPTS=%QEMU_OPTS% -usb
SET QEMU_OPTS=%QEMU_OPTS% -device usb-kbd
SET QEMU_OPTS=%QEMU_OPTS% -device usb-tablet
SET QEMU_OPTS=%QEMU_OPTS% -netdev user,id=net0
SET QEMU_OPTS=%QEMU_OPTS% -device e1000-82545em,netdev=net0,id=net0,mac=%MAC_NETWORK_MAC%
SET QEMU_OPTS=%QEMU_OPTS% -device %DISK_CONTROLLER%,id=DISK

SET QEMU_OPTS=%QEMU_OPTS% -drive %BOOTLOADER_DRIVE%
SET QEMU_OPTS=%QEMU_OPTS% -device %BOOTLOADER_DEVICE%

IF NOT "%MAC_DVD%" == "NONE" (
    SET QEMU_OPTS=%QEMU_OPTS% -drive %CD_DRIVE%
    SET QEMU_OPTS=%QEMU_OPTS% -device %CD_DEVICE%
)

SET QEMU_OPTS=%QEMU_OPTS% -drive %HD1_DRIVE%
SET QEMU_OPTS=%QEMU_OPTS% -device %HD1_DEVICE%

IF NOT "%MAC_HD_2%" == "" (
    SET QEMU_OPTS=%QEMU_OPTS% -drive %HD2_DRIVE%
    SET QEMU_OPTS=%QEMU_OPTS% -device %HD2_DEVICE%
)

IF NOT "%MAC_HD_3%" == "" (
    SET QEMU_OPTS=%QEMU_OPTS% -drive %HD3_DRIVE%
    SET QEMU_OPTS=%QEMU_OPTS% -device %HD3_DEVICE%
)

IF NOT "%MAC_HD_4%" == "" (
    SET QEMU_OPTS=%QEMU_OPTS% -drive %HD4_DRIVE%
    SET QEMU_OPTS=%QEMU_OPTS% -device %HD4_DEVICE%
)


#echo %QEMU% %QEMU_OPTS%

%QEMU% %QEMU_OPT%
