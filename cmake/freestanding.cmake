# Common freestanding flags shared across all myos targets
add_library(myos_flags INTERFACE)
target_compile_options(myos_flags INTERFACE
    -m64
    -ffreestanding
    -fno-rtti
    -fno-exceptions
    -fno-zero-initialized-in-bss
    -fno-common
    -masm=intel
    -mno-sse
    -mno-sse2
    -mno-mmx
    -mno-3dnow
    -mno-80387
    -msoft-float
    -mno-red-zone
    $<$<CONFIG:Debug>:-g;-O0>
    $<$<CONFIG:Release>:-O2>
)
