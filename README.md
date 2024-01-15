# AMD Passthrough Fix
Created based on the information found in these sources:
- https://github.com/gnif/vendor-reset/issues/46
- https://www.nicksherlock.com/2020/11/working-around-the-amd-gpu-reset-bug-on-proxmox/
- https://github.com/gnif/vendor-reset
- https://pve.proxmox.com/wiki/PCI_Passthrough
- https://us.informatiweb.net/tutorials/it/bios/enable-iommu-or-vt-d-in-your-bios.html

## Proxmox notes:
This script was built with the intention of being used on Proxmox nodes, it will probably work other places as well however.
Special things to note about using Proxmox:
* You'll need to enable the `no-subscription` repository to get the headers.
    * You can do this in the Proxmox gui quite easily: Select the node > Updates > Repositories > Add (Click `OK` on prompt) > Change drop-down to `No-subscription` > Click `Add`
* To install the header files: `apt install pve-headers`
    * Reboot after installing them!

## Before you run:
* Make sure you have the **kernel headers** installed (as well as `git` and `dkms`)! The script will error out otherwise.
* Run script as root
* Note: This script is built for systems running systemd, because that's what Proxmox uses. In the future I might generalize it.

### IOMMU Interrupt Remapping
My test computers support interrupt rempping, therefor I cannot test the workaround for other systems.
Check [this link](https://pve.proxmox.com/wiki/PCI_Passthrough#Verify_IOMMU_interrupt_remapping_is_enabled) to find out your situation.

The script currently doesn't automatically add the kernel parameters to your grub config. [This page on the arch wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Enabling_IOMMU) tells you what to do. In short: 
* Intel CPU: `intel_iommu=on iommu=pt`
* AMD CPU: `iommu=pt`

## Troubleshooting
### My VM is crashing
According to [this](https://pve.proxmox.com/wiki/PCI_Passthrough#Tips) you may need to do this on your host:
```
echo "options kvm ignore_msrs=1 report_ignored_msrs=0" > /etc/modprobe.d/kvm.conf
```
Please read the link real quick to make sure this is *actually* what you need :)

### VM Boots but I have a black screen
I solved this by setting the gpu to not be for display.
