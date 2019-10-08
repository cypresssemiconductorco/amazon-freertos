# AFR calls GCC_ARM arm-gcc

get_filename_component(dir ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
include("${dir}/toolchains/GCC_ARM.cmake")
