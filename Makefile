USER = [seu_ususario]
PARTITION_ROOTFS = XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
PARTITION_ZIMAGE = XXXX-XXXX 
HOME_PATH = /home/$(USER)/[o_caminho]/[para]/[o_diretorio]/[do_build_root]
BUILDROOTPATH = buildroot-2024.08.1
ARM_GCC=arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-linux-gnueabihf
ARCH=arm
TARGET = all

install:
	bash -c "wget https://buildroot.org/downloads/buildroot-2024.08.1.tar.xz";
	bash -c "tar xvf buildroot-2024.08.1.tar.xz";
	bash -c "wget https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-linux-gnueabihf.tar.xz";
	bash -c "tar xvf arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-linux-gnueabihf.tar.xz";

	bash -c "cp -f .config buildroot-2024.08.1/.config"

	bash -c "sudo apt update";
	bash -c "sudo apt install flex";
	bash -c "sudo apt install bison";
	bash -c "sudo apt install libncurses5-dev";
	bash -c "sudo apt install g++";
	bash -c "sudo apt install bzip2";
	bash -c "sudo apt install git";
	bash -c "sudo apt install libssl-dev";

build:
	bash -c "make -C $(HOME_PATH)$(BUILDROOTPATH) ARCH=$(ARCH) ARM_GCC=$(HOME_PATH)$(ARM_GCC) $(TARGET) -j 8";

remove:
	bash -c "sudo rm -r /media/$(USER)/$(PARTITION_ROOTFS)/";
	bash -c "sync";

deploy:
	bash -c "sudo tar xvf buildroot-2024.08.1/output/images/rootfs.tar -C /media/$(USER)/$(PARTITION_ROOTFS)/";
	bash -c "sync";
	bash -c "cp -f buildroot-2024.08.1/output/images/zImage /media/$(USER)/$(PARTITION_ZIMAGE)/zImage";
