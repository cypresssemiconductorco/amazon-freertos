#!/bin/bash
#
# This file is used by make to create the build commands to sign an OTA image
#
# Modify at your peril !
#
# Arguments
# We have a lot
#
CY_OUTPUT_PATH=$1
shift
CY_OUTPUT_NAME=$1
shift
MCUBOOT_SCRIPT_FILE_DIR=$1
shift
IMGTOOL_SCRIPT_NAME=$1
shift
FLASH_ERASE_VALUE=$1
shift
MCUBOOT_HEADER_SIZE=$1
shift
MCUBOOT_MAX_IMG_SECTORS=$1
shift
CY_BUILD_VERSION=$1
shift
CY_BOOT_PRIMARY_1_START=$1
shift
CY_BOOT_PRIMARY_1_SIZE=$1
shift
SIGNING_KEY_PATH=$1
shift
APP_DIR=$1
#

# Export these values for python3 click module
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
    
CY_OUTPUT_BIN=$CY_OUTPUT_PATH/$CY_OUTPUT_NAME.bin
CY_OUTPUT_ELF=$CY_OUTPUT_PATH/$CY_OUTPUT_NAME.elf
CY_OUTPUT_HEX=$CY_OUTPUT_PATH/$CY_OUTPUT_NAME.hex
CY_OUTPUT_SIGNED_HEX=$CY_OUTPUT_PATH/$CY_OUTPUT_NAME.signed.hex
CY_OUTPUT_FILE_PATH_WILD=$CY_OUTPUT_PATH/$CY_OUTPUT_NAME.*
#
# Leave here for debugging
#echo " CY_OUTPUT_NAME           $CY_OUTPUT_NAME"
#echo " CY_OUTPUT_BIN            $CY_OUTPUT_BIN"
#echo " CY_OUTPUT_ELF            $CY_OUTPUT_ELF"
#echo " CY_OUTPUT_HEX            $CY_OUTPUT_HEX"
#echo " CY_OUTPUT_SIGNED_HEX     $CY_OUTPUT_SIGNED_HEX"
#echo " MCUBOOT_SCRIPT_FILE_DIR  $MCUBOOT_SCRIPT_FILE_DIR"
#echo " IMGTOOL_SCRIPT_NAME      $IMGTOOL_SCRIPT_NAME"
#echo " FLASH_ERASE_VALUE        $FLASH_ERASE_VALUE"
#echo " MCUBOOT_HEADER_SIZE      $MCUBOOT_HEADER_SIZE"
#echo " MCUBOOT_MAX_IMG_SECTORS  $MCUBOOT_MAX_IMG_SECTORS"
#echo " CY_BUILD_VERSION         $CY_BUILD_VERSION"
#echo " CY_BOOT_PRIMARY_1_START  $CY_BOOT_PRIMARY_1_START"
#echo " CY_BOOT_PRIMARY_1_SIZE   $CY_BOOT_PRIMARY_1_SIZE"
#echo " SIGNING_KEY_PATH         $SIGNING_KEY_PATH"
#
# For FLASH_ERASE_VALUE
# If value is 0x00, we need to specify "-R 0"
# If value is 0xFF, we do not specify anything!
#
FLASH_ERASE_ARG=
if [ $FLASH_ERASE_VALUE -eq 0 ]
then 
FLASH_ERASE_ARG="-R 0"
fi

#
set -e
echo "Create  $CY_OUTPUT_HEX"
arm-none-eabi-objcopy -O ihex $CY_OUTPUT_ELF $CY_OUTPUT_HEX
echo ""
#echo  "Compile size (useful for debugging the build):" 
#arm-none-eabi-size "--format=SysV" $CY_OUTPUT_ELF
echo ""
echo  "Signing Hex, creating bin."
cd $MCUBOOT_SCRIPT_FILE_DIR
python3 $IMGTOOL_SCRIPT_NAME sign $FLASH_ERASE_ARG -e little --align 8 -H $MCUBOOT_HEADER_SIZE -M $MCUBOOT_MAX_IMG_SECTORS -v $CY_BUILD_VERSION -L $CY_BOOT_PRIMARY_1_START -S $CY_BOOT_PRIMARY_1_SIZE -k $SIGNING_KEY_PATH $CY_OUTPUT_HEX $CY_OUTPUT_SIGNED_HEX
#
# Convert signed hex file to Binary for AWS uploading
objcopy --input-target=ihex --output-target=binary $CY_OUTPUT_SIGNED_HEX $CY_OUTPUT_BIN
echo  " Done."
echo ""
echo "Application Name                         : $CY_OUTPUT_NAME"
echo "Application Version                      : $CY_BUILD_VERSION"
echo "Primary 1 Slot Start                     : $CY_BOOT_PRIMARY_1_START"
echo "Primary 1 Slot Size                      : $CY_BOOT_PRIMARY_1_SIZE"
echo "FLASH ERASE Value (NOTE: Empty for 0xff) : $FLASH_ERASE_VALUE"
echo "Cypress MCUBoot Header size              : $MCUBOOT_HEADER_SIZE"
echo "Max 512 bytes sectors for Application    : $MCUBOOT_MAX_IMG_SECTORS"
echo "Signing key: $SIGNING_KEY_PATH"
echo ""
#
ls -l $CY_OUTPUT_FILE_PATH_WILD
echo ""
