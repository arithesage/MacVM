# [WIP] Mac VMs

For easily emulating and virtualizing Mac machines.

This repositry is meant to be both practical (you have the needed things
for virtualizing the diverse Mac OS versions, from the classic ones up to
the most modern ones without quickly) and educational, because you have
both the files, the docs, and the notes, to create you own OpenCore
bootloader if you wish.

I have spent many hours testing diverse configurations, drivers and speaking
with Chat-GPT in order to have this functional (it would be great if the
Chat-GPT AI could have all the work done for you, but it is far from being
really useful).


I have structured the repo in this way:

- bootloader folder: Holds various OpenCore images, needed to boot all the
  modern OS (starting with Leopard in Intel machines).

  Each one represent a lot of hours (and even days) spent in testing
  configurations and drivers.

- EFI: Contains the OVMF (Open Virtual Machine Firmware), that is the EFI
  that allows to load the OpenCore bootloader.

- harddrives and iso folders: They aren't really required, you can specify
  the full path of the images to use in the scripts that launches every OS.

- utils folder: Some useful programs. Especially GenSMBIOS and ProperTree,
  meant to be used when creating a new OpenCore image.

- extra folder: A lot of stuff is included there.
    - bootloader folder: Base OpenCore images. Only include the basic files,
      without any additional kext, driver or config.

    - docs: Useful docs.

    - Drivers and kexts: Extra drivers and kext that may be needed when
      creating a new OpenCore image.

    - OcBinaryData folder: The content of the OcBinaryData repository.
      Contains both drivers and resources for OpenCore.

    - OpenCore-X.X.X-DEBUG/RELEASE folders: The contents of the OpenCore
      repository being used. Available in both debug and release versions.

    - OVMF folder: Default OVMF files. For restoring OVMF_VARS, for example.

- boot_intel_mac: This script is the one use for booting any Intel based
  Mac VM.

- boot_ppc_mac: Script for booting PowerPC based Mac VMs.

- boot_osname: There are a bunch of these scripts. They boots every Mac
  ever made, and includes basically the needed configuration and the
  call for the needed boot script.

  You can alter these script in any way you want, to give the VM more RAM,
  boot it with one or more extra harddrives, adding a DVD for reinstalling
  the OS... but i would not recommend modifying the boot_intel/ppc_mac
  scripts, because they are quite complex.

  Unless you know what are you doing, of course.





