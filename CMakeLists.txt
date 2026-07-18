cmake_minimum_required(VERSION 3.20)
project(myosystem CXX ASM)

# IDE(VS)에서 대상들을 FOLDER 속성으로 그룹핑 허용 (mytools 하나로 묶기 위함)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# freestanding: 스택 프로텍터 런타임(__stack_chk_fail/guard)이 없으므로 카나리 비활성화.
# (켜져 있으면 배열 있는 함수가 ud2/#GP로 터짐) — 모든 서브디렉터리 타깃에 적용
add_compile_options(-fno-stack-protector)

# 비-void 함수에서 return 누락 → 컴파일 에러 (Pipe::read 같은 ud2 런타임 크래시 원천 차단)
add_compile_options(-Werror=return-type)

# preset 없이 configure 시 빈 CMAKE_BUILD_TYPE → 경로/최적화 깨짐 방지 (기본 Debug)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
endif()

set(BOOT_OUT_DIR ${CMAKE_SOURCE_DIR}/_bootpartition/x64/${CMAKE_BUILD_TYPE})

include(cmake/freestanding.cmake)

add_subdirectory(mylibc)
add_subdirectory(mydisplay)
add_subdirectory(mygui)
add_subdirectory(myshell)
add_subdirectory(myterminal)
add_subdirectory(mytools)
add_subdirectory(myprograms)
add_subdirectory(mykernel)

add_custom_target(makeimg ALL
    COMMAND bash -c "set -e && LOOP=$(sudo losetup -f) && sudo losetup -P $LOOP ${CMAKE_SOURCE_DIR}/myos.img && sudo mkdir -p /mnt/efi && sudo mount \"$LOOP\"p1 /mnt/efi && sudo rm -rf /mnt/efi/* && sudo cp -r ${BOOT_OUT_DIR}/* /mnt/efi/ && sudo umount /mnt/efi && sudo losetup -d $LOOP && echo [*] Done."
    DEPENDS mykernel kernel_stubs myshell myterminal mygui mydisplay tools_all programs_all
    COMMENT "Creating disk image..."
    VERBATIM
)
