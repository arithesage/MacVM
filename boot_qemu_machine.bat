@ECHO OFF

function abort
{
    REASON=$1

    if ! [ "$REASON" == "" ];
    then
        echo "${REASON}"
    fi

    echo "Aborting."
    echo ""

    exit 1
}


if [ "$1" == "-h" ] || [ "$1" == "--help" ];
then
    echo "Launch a QEMU virtual machine."
    echo ""
    echo "To configure the VM, you need to set some environment variables."
    echo "Here are the ones used: "
    echo "----------------------------------------------------------------"

    echo "----------------------------------------------------------------"
    echo "You can also add whatever you want with the QVM_EXTRA_OPTS one."
    echo "Remember to separate each parameter with a space and every"
    echo "parameter option with a comma." 
    echo ""

    abort
fi


SCRIPT_DIR=$(realpath $(dirname $0))




if [ "$QVM_ARCH" == "" ];
then
    QVM_ARCH=$(uname -m)

    echo "No architecture given. Using host's by default."
else
    echo "Using ${QVM_ARCH} architecture."
fi

QEMU="qemu-system-${QVM_ARCH}"
QEMU_OPTS=""


if ! [ "$QVM_NAME" == "" ];
then
    QEMU_OPTS+="-name \"${QVM_NAME}\" "
fi


if ! [ "$QVM_MACHINE" == "" ];
then
    QEMU_OPTS+="-machine ${QVM_MACHINE}"
    echo "Creating a ${QVM_MACHINE} virtual machine."

else
    QEMU_OPTS+="-machine q35"
    echo "Using a Q35 machine by default."
fi


if [ "$QVM_ARCH" == "$(uname -m)" ];
then
    echo ""
    echo "The machine architecture matchs host's one."
    echo "Enabling KVM acceleration."
    echo ""

    QEMU_OPTS+=",accel=kvm "
else
    QEMU_OPTS+=" "
fi


if ! [ "$QVM_BIOS" == "" ];
then
    if ! [ "$QVM_BIOS" == "DEFAULT" ];
    then
        QEMU_OPTS+="-bios ${QVM_BIOS} "
        echo "Using '${QVM_BIOS}' BIOS."

    else
        echo "Using default BIOS."
    fi

elif ! [ "$QVM_EFI" == "" ];
then
    QEMU_OPTS+="-drive if=pflash,format=raw,readonly=on"
    QEMU_OPTS+=",file=${QVM_EFI} "

    if [ "$QVM_EFI_VARS" == "" ];
    then
        abort "No QVM_EFI_VARS (OVMF_VARS.fd path) given."
    fi

    QEMU_OPTS+="-drive if=pflash,format=raw"
    QEMU_OPTS+=",file=${QVM_EFI_VARS} "

    echo "Using UEFI ${QVM_EFI}."

else
    echo "No QVM_BIOS or QVM_EFI provided. Will use default BIOS."
fi


if ! [ "$QVM_CPU" == "" ];
then
    QEMU_OPTS+="-cpu ${QVM_CPU}"

    echo ""
    echo "Using ${QVM_CPU}."

    if ! [ "$QVM_CPU_OPTS" == "" ];
    then
        QEMU_OPTS+=",${QVM_CPU_OPTS}"
        echo "CPU options: ${QVM_CPU_OPTS}"
    fi

    if ! [ "$QVM_CPU_CORES" = "" ];
    then
        QEMU_OPTS+=" -smp ${QVM_CPU_CORES}"
        echo "${QVM_CPU_CORES} core/s."
        echo ""
    fi

    QEMU_OPTS+=" "

else
    echo "No QVM_CPU provided. Will use the host's CPU."
fi


if ! [ "$QVM_RAM" == "" ];
then
    QEMU_OPTS+="-m ${QVM_RAM} "
    echo "Using ${QVM_RAM} of RAM."
else
    QEMU_OPTS+="-m 16M "
    echo "Using 16 MB of RAM by default."
fi


if ! [ "$QVM_VGA" == "" ];
then
    QEMU_OPTS+="-vga ${QVM_VGA} "
    echo "Using ${QVM_VGA} VGA."
else
    QEMU_OPTS+="-vga std "
    echo "Using standard VGA."
fi


if ! [ "$QVM_VIDEO_DEVICE" == "" ];
then
    QEMU_OPTS+="-device ${QVM_VIDEO_DEVICE} "
    echo "Using ${QVM_VIDEO_DEVICE} video device."
fi


if ! [ "$QVM_AUDIO" == "" ];
then
    QEMU_OPTS+="-device ${QVM_AUDIO}"
    echo "Enabled '${QVM_AUDIO}' audio."
    
    if ! [ "$QVM_AUDIO_DEVICE_OPTS" == "" ];
    then
        QEMU_OPTS+=",${QVM_AUDIO_DEVICE_OPTS} "
        echo "With options: ${QVM_AUDIO_DEVICE_OPTS}"
    else
        QEMU_OPTS+=" "
    fi
fi


if ! [ "$QVM_DISPLAY" == "" ];
then
    if [ "$QVM_DISPLAY" == "NONE" ];
    then
        QEMU_OPTS+="-display none "
    else
        QEMU_OPTS+="-display ${QVM_DISPLAY} "
    fi
else
    QEMU_OPTS+="-display gtk "
    
    echo "Using GTK for the display Window."
fi


if ! [ "$QVM_SPICE_PORT" == "" ];
then
    QEMU_OPTS+="-spice port=${QVM_SPICE_PORT},addr=0.0.0.0"
    
    if ! [ "$QVM_SPICE_OPTS" == "" ];
    then
        QEMU_OPTS+=",${QVM_SPICE_OPTS} "
    else
        QEMU_OPTS+=",disable-ticketing=on "
    fi
fi


if [ "$QVM_INCLUDE_USB" == "1" ];
then
    QEMU_OPTS+="-usb "
fi


if [ "$QVM_INCLUDE_NETWORK" == "1" ];
then
    if ! [ "$QVM_NETWORK_TYPE" == "" ];
    then
        QEMU_OPTS+="-netdev ${QVM_NETWORK_TYPE},id=net0 "
    else
        QEMU_OPTS+="-netdev user,id=net0 "

        echo ""
        echo "Using user networking by default."
        echo "VM will be unreachable but it will be able to connect to hosts."
        echo ""
    fi

    if ! [ "$QVM_NETWORK_CARD" == "" ];
    then
        QEMU_OPTS+="-device ${QVM_NETWORK_CARD}"
    else
        QEMU_OPTS+="-device e1000-82545em"
    fi

    if ! [ "$QVM_NETWORK_OPTS" == "" ];
    then
        QEMU_OPTS+=",${QVM_NETWORK_OPTS}"
    fi

    if ! [ "$QVM_NETWORK_CARD_MAC" == "" ];
    then
        QEMU_OPTS+=",mac=${QVM_NETWORK_CARD_MAC}"
    fi

    QEMU_OPTS+=",netdev=net0,id=net0 "
fi


if ! [ "$QVM_IDE_0_MASTER" == "" ];
then
    if [[ $QVM_IDE_0_MASTER == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_IDE_0_MASTER},if=ide,index=0"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "

    echo "Connected '${QVM_IDE_0_MASTER}' to IDE 0 (Master)"
fi

if ! [ "$QVM_IDE_0_SLAVE" == "" ];
then
    if [[ $QVM_IDE_0_SLAVE == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_IDE_0_SLAVE},if=ide,index=1"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "

    echo "Connected '${QVM_IDE_0_SLAVE}' to IDE 0 (Slave)"
fi

if ! [ "$QVM_IDE_1_MASTER" == "" ];
then
    if [[ $QVM_IDE_1_MASTER == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_IDE_1_MASTER},if=ide,index=2"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "

    echo "Connected '${QVM_IDE_1_MASTER}' to IDE 1 (Master)"
fi

if ! [ "$QVM_IDE_1_SLAVE" == "" ];
then
    if [[ $QVM_IDE_1_SLAVE == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_IDE_1_SLAVE},if=ide,index=3"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "

    echo "Connected '${QVM_IDE_1_SLAVE}' to IDE 1 (Slave)"
fi


if ! [ "$QVM_SATA_0" == "" ] || ! [ "$QVM_SATA_1" == "" ] || \
   ! [ "$QVM_SATA_2" == "" ] || ! [ "$QVM_SATA_3" == "" ] || \
   ! [ "$QVM_SATA_4" == "" ] || ! [ "$QVM_SATA_5" == "" ];
then
    if [ "$QVM_SATA_CONTROLLER" == "" ];
    then
        QVM_SATA_CONTROLLER="-device ich9-achi"
    fi

    QEMU+="-device ${QVM_SATA_CONTROLLER},id=sata "

    echo "Enabled SATA controller '${QVM_SATA_CONTROLLER}'"
fi


if ! [ "$QVM_SATA_0" == "" ];
then
    if [[ $QVM_SATA_0 == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_SATA_0},if=none,id=sata0"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "
    QEMU_OPTS+="-device ide-hd,drive=sata0,bus=sata.0 "

    echo "Connected '${QVM_SATA_0}' to SATA.0"
fi

if ! [ "$QVM_SATA_1" == "" ];
then
    if [[ $QVM_SATA_1 == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_SATA_1},if=none,id=sata1"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "
    QEMU_OPTS+="-device ide-hd,drive=sata1,bus=sata.1 "

    echo "Connected '${QVM_SATA_1}' to SATA.1"
fi

if ! [ "$QVM_SATA_2" == "" ];
then
    if [[ $QVM_SATA_2 == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_SATA_2},if=none,id=sata2"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "
    QEMU_OPTS+="-device ide-hd,drive=sata2,bus=sata.2 "

    echo "Connected '${QVM_SATA_2}' to SATA.2"
fi

if ! [ "$QVM_SATA_3" == "" ];
then
    if [[ $QVM_SATA_3 == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_SATA_3},if=none,id=sata3"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "
    QEMU_OPTS+="-device ide-hd,drive=sata3,bus=sata.3 "

    echo "Connected '${QVM_SATA_3}' to SATA.3"
fi

if ! [ "$QVM_SATA_4" == "" ];
then
    if [[ $QVM_SATA_4 == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_SATA_4},if=none,id=sata4"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "
    QEMU_OPTS+="-device ide-hd,drive=sata4,bus=sata.4 "

    echo "Connected '${QVM_SATA_4}' to SATA.4"
fi

if ! [ "$QVM_SATA_5" == "" ];
then
    if [[ $QVM_SATA_5 == *.qcow2 ]];
    then
        IMAGE_FORMAT="qcow2"
    else
        IMAGE_FORMAT="raw"
    fi

    QEMU_OPTS+="-drive file=${QVM_SATA_5},if=none,id=sata5"
    QEMU_OPTS+=",format=${IMAGE_FORMAT} "
    QEMU_OPTS+="-device ide-hd,drive=sata5,bus=sata.5 "

    echo "Connected '${QVM_SATA_5}' to SATA.5"
fi


if not "%QVM_SATA_EXTRA_DRIVES%" == "" (
then
    SET QEMU_OPTS=%QEMU_OPTS% %QEMU_SATA_EXTRA_DRIVES%
)


if not "%QVM_EXTRA_DEVICES%" == "" (
    SET QEMU_OPTS=%QEMU_OPTS% %QVM_EXTRA_DEVICES%
)


if not "%QVM_EXTRA_OPTS%" == "" (
    SET QEMU_OPTS=%QEMU_OPTS% %QVM_EXTRA_OPTS%
)


if "%QVM_SHOW_CMDLINE%" == "1" (
    echo ""
    echo "Running %QEMU% %QEMU_OPTS% ..."
    echo ""
)

%QEMU% %QEMU_OPTS%
