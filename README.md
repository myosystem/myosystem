<div align="center">

  # MYOSYSTEM
  
  **A 64-bit Operating System written in Modern C++**
  
  <br>
  
  <p>
    <a href="https://isocpp.org/" title="C++">
      <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/cplusplus/cplusplus-original.svg" alt="C++" width="50" height="50"/>
    </a>
    &nbsp;&nbsp;&nbsp; <a href="https://visualstudio.microsoft.com/" title="Visual Studio">
      <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/visualstudio/visualstudio-plain.svg" alt="VS" width="50" height="50"/>
    </a>
  </p>

  ![C++](https://img.shields.io/badge/Language-C++20-00599C?style=flat-square&logo=c%2B%2B&logoColor=white)
  ![Arch](https://img.shields.io/badge/Arch-x86__64-orange?style=flat-square&logo=intel&logoColor=white)
  ![Boot](https://img.shields.io/badge/Boot-UEFI-green?style=flat-square&logo=uefi&logoColor=white)
  ![License](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)
</div>
<br>

## System Architecture

### 1. MyBootloader (UEFI Bootloader)
* **Tech:** EDK2 Framework
* **Role:** Reads the UEFI memory map to build the **physical-page bitmap + per-page refcount array**, sets up **4-level paging & HHDM**, acquires the **GOP framebuffer**, locates the **ACPI RSDP**, loads the GDT, then calls `ExitBootServices` and jumps to the kernel per the **Boot Protocol**.

### 2. MyKernel (The Core)
* **Tech:** C++20, GNU Toolchain (GCC/LD)
* **Role:** Core resource management — memory & paging, preemptive scheduling, interrupts, IPC, VFS, and device drivers.

### 3. MyDisplay (Graphics Subsystem)
* **Tech:** Linear Framebuffer (Hardware Agnostic)
* **Role:** A dedicated graphics server rendering to the framebuffer provided by the bootloader.

### 4. MyLibc (Custom Standard Library)
* **Tech:** Freestanding C++
* **Role:** A scratch-built implementation of the standard library with no external dependencies.

### 5. MyGUI (Desktop Shell)
* **Tech:** Message-driven client of MyDisplay
* **Role:** Window manager / app launcher; routes keyboard & mouse input to the focused window.

### 6. MyTerminal & MyShell (Console)
* **Tech:** Pipe + message IPC
* **Role:** Terminal emulator (window, character grid, ANSI escapes, keyboard & line-discipline) hosting **MyShell**, a stdin/stdout command interpreter. Cleanly split so any program can share the TTY.

### 7. MyTools (Coreutils)
* **Tech:** Freestanding userspace programs
* **Role:** Command-line utilities (`ls`, `dir`, `echo`, `type`, `mkdir`, `rmdir`, `rm`, `clear`) exercising full file CRUD.

---

## Features

* **Memory:** 4-level paging, physical-bitmap + virtual-page allocators, HHDM, demand-mapped indexed object pools (`NewObject`).
* **Reference counting:** per-physical-page refcounts back Copy-on-Write; `File`, `Pipe`, and shared-memory handles are refcounted for safe sharing across `fork` / `dup`.
* **Processes:** preemptive scheduler, Copy-on-Write `fork` / `exec`, zombie reaping, inherited controlling terminal (console).
* **IPC:** fixed-size messages (unicast **and broadcast**, unknown types dropped), byte-stream pipes (non-blocking + readiness-notify), shared memory.
* **Filesystem:** GPT partitioning, FAT32 with **full CRUD** (create / read / write / truncate / delete, `mkdir` / `rmdir`), multi-partition support.
* **Storage drivers:** NVMe, AHCI (SATA), xHCI (USB mass storage).
* **Input:** USB HID mouse + keyboard over xHCI (HID report-descriptor parsing).
* **Graphics:** linear-framebuffer compositor — per-window buffers, z-ordering, transparency, click hit-testing.
* **Power (ACPI):** proper shutdown (S5 via FADT + `_S5`) and reboot (FADT reset register), with 8042 / emulator fallbacks.

---

## Technical Specifications

### 1. System Requirements
Minimum environment requirements to execute the OS.

| Component | Requirement | Note |
| :--- | :--- | :--- |
| **Firmware** | UEFI 2.x+ | Legacy BIOS support planned via protocol. |
| **CPU** | x86_64 | Must support **Long Mode**. |
| **Memory** | 512 MB+ | Required for Framebuffer & Kernel Heap. |
| **Graphics** | Linear Framebuffer | GOP (UEFI) or VBE (BIOS) compatible. |

### 2. Kernel Boot Protocol
The kernel is **bootloader-agnostic**. It requires the bootloader to establish the following machine state before passing control.

#### Memory Layout & State
State at **Kernel Entry Point**:

| Region | Virtual Address | Description |
| :--- | :--- | :--- |
| **Boot Info** | `0xFFFFFFFF00200000` | Location of `BootInfo` structure. |
| **Kernel Entry** | `0xFFFFFFFF80000000` | Kernel text section entry address. |
| **Paging** | `Enabled` | 4-Level Paging active. |
| **HHDM** | `0xFFFFFF0000000000` | Physical memory mapping base offset. |

#### BootInfo Structure
The bootloader must populate this structure at `0xFFFFFFFF00200000`.

```cpp
typedef struct {
    uint8_t  type;
    uint16_t pci_bus;
    uint16_t pci_slot;
    uint16_t pci_func;
    uint32_t port_or_ns;
} boot_device_info_t;

typedef struct {
    uint64_t framebufferAddr;
    uint32_t framebufferWidth;
    uint32_t framebufferHeight;
    uint32_t framebufferPitch;
    uint32_t framebufferFormat;

    uint64_t* physbm;
    uint64_t* refcount;
    uint64_t  physbm_size;
    
    void* rsdp;
    boot_device_info_t bootdev;
} BootInfo;
```
