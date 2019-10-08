
# -------------------------------------------------------------------------------------------------
# Configure ModusToolbox cmake environment
# -------------------------------------------------------------------------------------------------

function(cy_kit_generate)
    cmake_parse_arguments(
    PARSE_ARGV 0
    "ARG"
    ""
    "DEVICE;LINKER_SCRIPT;COMPONENTS;DEFINES"
    ""
    )

set(cy_pso6_dir "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/psoc6")
set(cy_whd_dir "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/whd")
set(cy_clib_dir "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/clib_support")

include("${cy_pso6_dir}/cmake/cy_utils.cmake")
if(EXISTS "${cy_pso6_dir}/cmake/toolchains/${AFR_TOOLCHAIN}.cmake")
    include("${cy_pso6_dir}/cmake/toolchains/${AFR_TOOLCHAIN}.cmake")
elseif(AFR_METADATA_MODE)
    function(cy_cfg_toolchain)
    endfunction()
    set(ENV{CY_FREERTOS_TOOLCHAIN} GCC)
else()
    message(FATAL_ERROR "Unsupported toolchain: ${AFR_TOOLCHAIN}")
endif()

set(board_demos_dir "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/boards/${AFR_BOARD_NAME}/aws_demos")
set(board_tests_dir "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/boards/${AFR_BOARD_NAME}/aws_tests")
if(AFR_IS_TESTING)
    set(board_dir "${board_tests_dir}")
    set(aws_credentials_include "${AFR_TESTS_DIR}/include")
    set(iot_common_include "${AFR_ROOT_DIR}/tests/include")
else()
    set(board_dir "${board_demos_dir}")
    set(aws_credentials_include "${AFR_DEMOS_DIR}/include")
    set(iot_common_include "${AFR_ROOT_DIR}/demos/include")
endif()

cy_cfg_env(
    TARGET "${AFR_BOARD_NAME}"
    DEVICE "${ARG_DEVICE}"
    TOOLCHAIN "${AFR_TOOLCHAIN}"
    LINKER_PATH "${board_dir}/application_code/cy_code"
    LINKER_SCRIPT "${ARG_LINKER_SCRIPT}"
    COMPONENTS "${AFR_BOARD_NAME};SOFTFP;BSP_DESIGN_MODUS;FREERTOS;${ARG_COMPONENTS}"
    ARCH_DIR "${cy_pso6_dir};${cy_whd_dir};${cy_clib_dir}"
)

# -------------------------------------------------------------------------------------------------
# Configure ModusToolbox target (used to build ModusToolbox firmware)
# -------------------------------------------------------------------------------------------------

set(ports_dir "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/boards/${AFR_BOARD_NAME}/ports")

cy_find_files(exe_files DIRECTORY "${board_dir}")
cy_get_src(exe_src ITEMS "${exe_files}")
cy_get_includes(exe_inc ITEMS "${exe_files}" ROOT "${board_dir}")
cy_get_libs(exe_libs ITEMS "${exe_files}")

cy_find_files(mtb_files DIRECTORY "$ENV{CY_ARCH_DIR}")
cy_get_src(mtb_src ITEMS "${mtb_files}")
cy_get_includes(mtb_inc ITEMS "${mtb_files}" ROOT "$ENV{CY_ARCH_DIR}")
cy_get_libs(mtb_libs ITEMS "${mtb_files}")

# -------------------------------------------------------------------------------------------------
# Compiler settings
# -------------------------------------------------------------------------------------------------
# If you support multiple compilers, you can use AFR_TOOLCHAIN to conditionally define the compiler
# settings. This variable will be set to the file name of CMAKE_TOOLCHAIN_FILE. It might also be a
# good idea to put your compiler settings to different files and just include them here, e.g.,
# include(compilers/${AFR_TOOLCHAIN}.cmake)

afr_mcu_port(compiler)
cy_add_args_to_target(
    AFR::compiler::mcu_port INTERFACE
    OPTIMIZATION "$ENV{OPTIMIZATION}"
    DEBUG_FLAG "$ENV{DEBUG_FLAG}"
    DEFINE_FLAGS "$ENV{DEFINE_FLAGS}"
    COMMON_FLAGS "$ENV{COMMON_FLAGS}"
    VFP_FLAGS "$ENV{VFP_FLAGS}"
    CORE_FLAGS "$ENV{CORE_FLAGS}"
    ASFLAGS "$ENV{ASFLAGS}"
    LDFLAGS "$ENV{LDFLAGS}"
)
cy_add_std_defines(AFR::compiler::mcu_port INTERFACE)
target_compile_definitions(
    AFR::compiler::mcu_port INTERFACE
    CYBSP_WIFI_CAPABLE
    CY_RTOS_AWARE
    CY_USING_HAL
    ${ARG_DEFINES}
)

# -------------------------------------------------------------------------------------------------
# Amazon FreeRTOS portable layers
# -------------------------------------------------------------------------------------------------
# Define portable layer targets with afr_mcu_port(<module_name>). We will create an CMake
# INTERFACE IMPORTED target called AFR::${module_name}::mcu_port for you. You can use it with
# standard CMake functions like target_*. To better organize your files, you can define your own
# targets and use target_link_libraries(AFR::${module_name}::mcu_port INTERFACE <your_targets>)
# to provide the public interface you want expose.

# Kernel
afr_mcu_port(kernel)
file(GLOB cy_freertos_port_src ${AFR_KERNEL_DIR}/portable/$ENV{CY_FREERTOS_TOOLCHAIN}/ARM_CM4F/*.[chsS])
target_sources(
    AFR::kernel::mcu_port
    INTERFACE
    ${cy_freertos_port_src}
    "${AFR_KERNEL_DIR}/portable/MemMang/heap_4.c"

)
target_include_directories(
    AFR::kernel::mcu_port
    INTERFACE
    ${exe_inc}
    ${mtb_inc}
    "${AFR_KERNEL_DIR}/include"
    "${AFR_KERNEL_DIR}/portable/$ENV{CY_FREERTOS_TOOLCHAIN}/ARM_CM4F"	# for portmacro.h
    "${iot_common_include}"                     # for iot_config_common.h
    "${AFR_3RDPARTY_DIR}/lwip/src/include"
    "${AFR_3RDPARTY_DIR}/lwip/src/include/lwip"
    "${AFR_3RDPARTY_DIR}/lwip/src/portable/arch"
    "${AFR_3RDPARTY_DIR}/lwip/src/portable"
)

add_library(CyObjStore INTERFACE)
target_sources(CyObjStore INTERFACE
    "${cy_pso6_dir}/mw/objstore/cyobjstore.c"
    "${cy_pso6_dir}/mw/emeeprom/cy_em_eeprom.c"
)
target_include_directories(
    CyObjStore
    INTERFACE
    "${cy_pso6_dir}/mw/emeeprom"
    "${cy_pso6_dir}/mw/objstore"
)

# WiFi
afr_mcu_port(wifi DEPENDS CyObjStore)
target_sources(
    AFR::wifi::mcu_port
    INTERFACE
    "${ports_dir}/wifi/iot_wifi.c"
    "${ports_dir}/wifi/iot_wifi_lwip.c"
    "${AFR_3RDPARTY_DIR}/lwip/src/portable/arch/sys_arch.c"
)
target_include_directories(
    AFR::wifi::mcu_port
    INTERFACE
    "${ports_dir}/wifi"
)
target_link_libraries(
    AFR::wifi::mcu_port
    INTERFACE
    3rdparty::lwip
)

# BLE
# set(BLE_SUPPORTED 1 CACHE INTERNAL "BLE is supported on this platform.")

if(BLE_SUPPORTED)
    afr_mcu_port(ble_hal)
    target_sources(
        AFR::ble_hal::mcu_port
        INTERFACE
        "${ports_dir}/ble/iot_ble_hal_manager.c"
        "${ports_dir}/ble/iot_ble_hal_manager_adapter_ble.c"
        "${ports_dir}/ble/iot_ble_hal_gatt_server.c"
        "${ports_dir}/ble/wiced_bt_cfg.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyosal/src/cybt_osal_amzn_freertos.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyosal/src/wiced_time_common.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_gpio.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_clock.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_uart.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_bluetooth.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/platform_bt_nvram.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/ring_buffer.c"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/src/bt_firmware_controller.c"
    )

    target_include_directories(
        AFR::ble_hal::mcu_port
        INTERFACE
        "${afr_ports_dir}/ble"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyosal/include"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/psoc6/cyhal/include"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/include"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/include/stackHeaders"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/objstore"
    )

    target_link_libraries(
        AFR::ble_hal::mcu_port
        INTERFACE
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/bluetooth.FreeRTOS.ARM_CM4.release.a"
        "${AFR_VENDORS_DIR}/${AFR_VENDOR_NAME}/bluetooth/shim.FreeRTOS.ARM_CM4.release.a"
    )

    target_compile_definitions(
        AFR::ble_hal::mcu_port
        INTERFACE
        BLE_SUPPORTED=1
    )
endif()

# Secure sockets
afr_mcu_port(secure_sockets)

target_link_libraries(
    AFR::secure_sockets::mcu_port
    INTERFACE
    AFR::tls
    AFR::secure_sockets_lwip
)

# PKCS11
afr_mcu_port(pkcs11_implementation DEPENDS CyObjStore)
target_sources(
    AFR::pkcs11_implementation::mcu_port
    INTERFACE
    "${ports_dir}/pkcs11/iot_pkcs11_pal.c"
)

# Link to AFR::pkcs11_mbedtls if you want to use default implementation based on mbedtls.
target_link_libraries(
    AFR::pkcs11_implementation::mcu_port
    INTERFACE AFR::pkcs11_mbedtls
)

# TODO: check if this is the correct way !!
target_sources(
    afr_3rdparty_mbedtls
    PUBLIC
    "${ports_dir}/pkcs11/hw_poll.c"
)

# OTA
# afr_mcu_port(ota)
# target_sources(
#     AFR::ota::mcu_port
#     INTERFACE "${AFR_MODULES_DIR}/ota/${portable_dir}/aws_ota_pal.c"
# )

# -------------------------------------------------------------------------------------------------
# Amazon FreeRTOS demos and tests
# -------------------------------------------------------------------------------------------------
# We require you to define at least demos and tests executable targets. Available demos and tests
# will be automatically enabled by us. You need to provide other project settings such as linker
# scripts and post build commands.

# ==================== Example ====================
set(CMAKE_EXECUTABLE_SUFFIX ".elf" PARENT_SCOPE)

if(AFR_IS_TESTING)
    set(exe_target aws_tests)
else()
    set(exe_target aws_demos)
endif()

add_executable(
    ${exe_target}
    ${exe_src}
    ${mtb_src}
)
target_link_libraries(
    ${exe_target}
    PRIVATE
    AFR::utils
    AFR::wifi
    AFR::wifi::mcu_port
    ${mtb_libs}
    ${exe_libs}
)

# add_custom_command(
#     TARGET ${exe_target} POST_BUILD
#     COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:${exe_target}>" "${CMAKE_BINARY_DIR}"
# )

endfunction()
