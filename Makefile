ASM=nasm
SRC_DIR=src
Build_DIR=build

##
# image
##
image: $(Build_DIR)/main.img
$(Build_DIR)/main.img: bootloader kernel
	dd if=/dev/zero of=$(Build_DIR)/main.img bs=512 count=2880
	mkfs.fat -F 12 -n "FAT_FILE" $(Build_DIR)/main.img
	dd if=$(Build_DIR)/bootloader.bin of=$(Build_DIR)/main.img conv=notrunc
	mcopy -i $(Build_DIR)/main.img $(Build_DIR)/kernel.bin ::/kernel.bin
##
# Bootloader
##
bootloader: $(Build_DIR)/bootloader.bin
$(Build_DIR)/bootloader.bin:
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(Build_DIR)/bootloader.bin




##
# kernel
##
kernel: $(Build_DIR)/kernel.bin
$(Build_DIR)/kernel.bin:
	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(Build_DIR)/kernel.bin

