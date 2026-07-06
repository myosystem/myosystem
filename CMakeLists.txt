cmake_minimum_required(VERSION 3.20)
project(myosystem CXX ASM)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(BOOT_OUT_DIR ${CMAKE_SOURCE_DIR}/_bootpartition/x64/${CMAKE_BUILD_TYPE})

include(cmake/freestanding.cmake)

add_subdirectory(mylibc)
add_subdirectory(mydisplay)
add_subdirectory(mygui)
add_subdirectory(myshell)
add_subdirectory(mytools)
add_subdirectory(mykernel)

add_custom_target(makeimg ALL
    COMMAND bash -c "set -e && LOOP=$(sudo losetup -f) && sudo losetup -P $LOOP ${CMAKE_SOURCE_DIR}/myos.img && sudo mkdir -p /mnt/efi && sudo mount \"$LOOP\"p1 /mnt/efi && sudo rm -rf /mnt/efi/* && sudo cp -r ${BOOT_OUT_DIR}/* /mnt/efi/ && sudo umount /mnt/efi && sudo losetup -d $LOOP && echo [*] Done."
    DEPENDS mykernel myshell mygui mydisplay
    COMMENT "Creating disk image..."
    VERBATIM
)
