# ============================================================================
# AERIS-10 STM32F746ZGT7 firmware build
# ============================================================================
# Part:      STM32F746ZGT7 (Cortex-M7, 1 MB flash, 320 KB RAM, 216 MHz, LQFP144)
# Toolchain: arm-none-eabi-gcc 15.x (brew --cask gcc-arm-embedded)
#
# Targets:
#   make              -- compile + link, produces firmware.elf/.bin/.hex (default)
#   make compile      -- compile only (stops at objects)
#   make clean        -- remove build/
# ============================================================================

# ---- toolchain -------------------------------------------------------------
PREFIX  := arm-none-eabi-
CC      := $(PREFIX)gcc
CXX     := $(PREFIX)g++
AS      := $(PREFIX)gcc -x assembler-with-cpp
LD      := $(PREFIX)g++
OBJCOPY := $(PREFIX)objcopy
SIZE    := $(PREFIX)size

# ---- tree ------------------------------------------------------------------
BUILD   := build
OBJDIR  := $(BUILD)/obj

VENDOR  := vendor
APP     := 9_1_3_C_Cpp_Code
LIB     := 9_1_1_C_Cpp_Libraries

# ---- target part + CPU flags ----------------------------------------------
MCU     := -mcpu=cortex-m7 -mthumb -mfpu=fpv5-sp-d16 -mfloat-abi=hard
DEFS    := -DSTM32F746xx -DUSE_HAL_DRIVER -DARM_MATH_CM7 -D__FPU_PRESENT=1

# ---- include paths (order matters; app overrides vendor on ambiguity) -----
INC := \
  -I$(APP) \
  -I$(LIB) \
  -I$(VENDOR)/cmsis_core/Include \
  -I$(VENDOR)/cmsis_device_f7/Include \
  -I$(VENDOR)/stm32f7xx_hal_driver/Inc \
  -I$(VENDOR)/stm32_mw_usb_device/Core/Inc \
  -I$(VENDOR)/stm32_mw_usb_device/Class/CDC/Inc

# ---- warnings / optimisation ----------------------------------------------
OPT      := -Og -g3
WARN     := -Wall -Wextra -Wno-unused-parameter -Wno-unused-function \
            -Wno-missing-field-initializers \
            -Wno-error=incompatible-pointer-types \
            -Wno-error=discarded-qualifiers \
            -Wno-error=int-conversion \
            -Wno-error=implicit-function-declaration
COMMON   := $(MCU) $(DEFS) $(INC) $(OPT) $(WARN) -ffunction-sections -fdata-sections -fno-common

CFLAGS   := $(COMMON) -std=gnu11
CXXFLAGS := $(COMMON) -std=gnu++17 -fno-exceptions -fno-rtti -fno-threadsafe-statics
ASFLAGS  := $(MCU) $(DEFS) -g3

# ---- sources ---------------------------------------------------------------
# App C/C++ — PR 2 adds usb_device.c, usbd_conf.c, usbd_desc.c, usbd_cdc_if.c
# (wildcard picks them up) and re-enables main.cpp + gps_handler.cpp.
APP_C   := $(wildcard $(APP)/*.c)
APP_CPP := $(wildcard $(APP)/*.cpp)
LIB_C   := $(wildcard $(LIB)/*.c)
LIB_CPP := $(wildcard $(LIB)/*.cpp)

# Vendor HAL: each _hal_<x>.c is guarded by HAL_<X>_MODULE_ENABLED in
# stm32f7xx_hal_conf.h, so compiling all of them is safe.  Skip ST's
# *_template.c stubs (user-copy boilerplate, not compile targets).
HAL_C   := $(filter-out %_template.c, $(wildcard $(VENDOR)/stm32f7xx_hal_driver/Src/*.c))
# USB Device library: Core + CDC class (skip *_template.c user stubs).
USB_C   := $(filter-out %_template.c, \
             $(wildcard $(VENDOR)/stm32_mw_usb_device/Core/Src/*.c) \
             $(wildcard $(VENDOR)/stm32_mw_usb_device/Class/CDC/Src/*.c))
# system_stm32f7xx.c already lives in 9_1_1_C_Cpp_Libraries/ (app-customised);
# drop the vendor copy to avoid duplicate symbols.
SYS_C   :=
STARTUP := $(VENDOR)/cmsis_device_f7/Source/Templates/gcc/startup_stm32f746xx.s

SRCS_C   := $(APP_C) $(LIB_C) $(HAL_C) $(USB_C) $(SYS_C)
SRCS_CPP := $(APP_CPP) $(LIB_CPP)
SRCS_S   := $(STARTUP)

OBJS := \
  $(patsubst %.c,$(OBJDIR)/%.o,$(SRCS_C)) \
  $(patsubst %.cpp,$(OBJDIR)/%.o,$(SRCS_CPP)) \
  $(patsubst %.s,$(OBJDIR)/%.o,$(SRCS_S))

DEPS := $(OBJS:.o=.d)

# ---- link ------------------------------------------------------------------
LDSCRIPT := linker/STM32F746ZGTx_FLASH.ld
LDFLAGS  := $(MCU) -T$(LDSCRIPT) -Wl,--gc-sections -Wl,-Map=$(BUILD)/firmware.map \
            -specs=nano.specs -specs=nosys.specs -static

ELF := $(BUILD)/firmware.elf
BIN := $(BUILD)/firmware.bin
HEX := $(BUILD)/firmware.hex

# ---- rules -----------------------------------------------------------------
.PHONY: all compile link clean size

all: link

compile: $(OBJS)
	@echo "compiled $(words $(OBJS)) objects"

link: $(ELF)

$(ELF): $(OBJS) $(LDSCRIPT)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ -lm
	$(SIZE) $@
	$(OBJCOPY) -O binary $@ $(BIN)
	$(OBJCOPY) -O ihex   $@ $(HEX)

$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(OBJDIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

$(OBJDIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD)

-include $(DEPS)
