# AMD Passthrough Fix
Created based on the information found in these sources:
- https://github.com/gnif/vendor-reset/issues/46
- https://www.nicksherlock.com/2020/11/working-around-the-amd-gpu-reset-bug-on-proxmox/
- https://github.com/gnif/vendor-reset
- https://pve.proxmox.com/wiki/PCI_Passthrough
- https://us.informatiweb.net/tutorials/it/bios/enable-iommu-or-vt-d-in-your-bios.html

## IOMMU Interrupt Remapping
My test computers support interrupt rempping, therefor I cannot test the workaround for other systems.
Check [this link](https://pve.proxmox.com/wiki/PCI_Passthrough#Verify_IOMMU_interrupt_remapping_is_enabled) to find out your situation.

## My VM is crashing
According to [this](https://pve.proxmox.com/wiki/PCI_Passthrough#Tips) you may need to do this on your host:
```
echo "options kvm ignore_msrs=1 report_ignored_msrs=0" > /etc/modprobe.d/kvm.conf
```
Please read the link real quick to make sure this is *actually* what you need :)