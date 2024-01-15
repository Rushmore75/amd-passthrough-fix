#!/bin/bash

if ! command -v dkms &> /dev/null; then echo "Install dkms" && exit; fi;
if ! command -v git &> /dev/null; then echo "Install git" && exit; fi;

echo "Assuming you are running 1 AMD GPU."
echo "Press CTRL-C to cancel. Press any key to proceed..."
read

# Check kernel options
KERNEL_OPTIONS=('CONFIG_FTRACE=' 'CONFIG_KPROBES=' 'CONFIG_PCI_QUIRKS=' 'CONFIG_KALLSYMS=' 'CONFIG_KALLSYMS_ALL=' 'CONFIG_FUNCTION_TRACER=')
MISSING=0
for OPTION in "${KERNEL_OPTIONS[@]}"; do
	if [[ $(grep $OPTION /boot/config-$(uname -r) | awk -F= '{print $2}') == "y" ]]; then
		echo "$OPTION ✅"
	else
		echo "$OPTION ❌"
		$MISSING=1
	fi
done
if (( $MISSING == 1 )); then
	echo "Error: Missing kernel option..."
	exit
fi


# Make sure IOMMU is enabled
if dmesg | grep -qe "DMAR: IOMMU enabled"; then echo IOMMU Enabled - continuing...;
else 
	echo IOMMU Not Enabled!
	echo "This link can help you enable it in your BIOS: https://us.informatiweb.net/tutorials/it/bios/enable-iommu-or-vt-d-in-your-bios.html"
 	echo "Also append \"intel_iommu=on\" for intel CPUs and \"iommu=pt\" for Intel & AMD to your \"GRUB_CMDLINE_LINUX_DEFAULT=\" line in /etc/default/grub"
  	echo "Then run update-grub"
	exit
fi

# Blacklist drivers on host machine
echo "blacklist amdgpu" >> /etc/modprobe.d/blacklist.conf
echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf

# Remove previous versions of vendor-reset
if dkms status | grep -q vendor-reset; then
	dkms remove $(dkms status | grep vendor-reset | awk -F: '{print $1}') --all
fi

# Get the vendor-reset patch and install it
git clone https://github.com/gnif/vendor-reset
cd vendor-reset
dkms install .
modprobe vendor-reset
update-initramfs -u

# Change gpu vendor reset method at startup
SCRIPT="/var/lib/vz/gpu-vendor-reset-method.sh"
echo "[Unit]
Description=Set the AMD GPU reset method to 'device_specific'
After=default.target

[Service]
ExecStart=/bin/bash $SCRIPT

[Install]
WantedBy=default.target
" > /etc/systemd/system/gpu-vendor-reset-method.service

# Finding correct pci device
DEVICE_ID=$(ls /sys/bus/pci/devices/ | grep $(lspci | grep VGA | grep AMD | awk '{print $1}'))

echo "#!/bin/sh
echo 'device_specific' > /sys/bus/pci/devices/$DEVICE_ID/reset_method
" > $SCRIPT
chmod +x $SCRIPT

systemctl enable gpu-vendor-reset-method.service

# Done!
echo ""
echo "Done!"
echo ""
echo "Now reboot for the changes to take effect."
