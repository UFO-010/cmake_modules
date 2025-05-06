#-- System ---------------------------------------------------------------------
SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR arm)

#-- Toolchain ------------------------------------------------------------------
SET(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
IF(WIN32)
    SET(TOOL_EXECUTABLE_SUFFIX ".exe")
ELSE()
    SET(TOOL_EXECUTABLE_SUFFIX "")
ENDIF()
SET(CMAKE_C_COMPILER "arm-none-eabi-gcc${TOOL_EXECUTABLE_SUFFIX}")
SET(CMAKE_CXX_COMPILER "arm-none-eabi-g++${TOOL_EXECUTABLE_SUFFIX}")
SET(CMAKE_ASM_COMPILER "arm-none-eabi-gcc${TOOL_EXECUTABLE_SUFFIX}")
SET(CMAKE_OBJCOPY "arm-none-eabi-objcopy${TOOL_EXECUTABLE_SUFFIX}" CACHE STRING "objcopy tool")
SET(CMAKE_OBJDUMP "arm-none-eabi-objdump${TOOL_EXECUTABLE_SUFFIX}" CACHE STRING "objdump tool")
SET(CMAKE_SIZE "arm-none-eabi-size${TOOL_EXECUTABLE_SUFFIX}" CACHE STRING "size tool")

SET(MCU_CORE_TYPE "cortex-m4")
SET(MCU_FPU_TYPE "-mfloat-abi=hard -mfpu=fpv4-sp-d16")

#-- Common flags ---------------------------------------------------------------
SET(COMPILER_COMMON_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE} ${MCU_FPU_TYPE} -Wall -Wextra -ffunction-sections -fdata-sections -mlong-calls")
SET(CMAKE_C_FLAGS "${COMPILER_COMMON_FLAGS} -std=gnu11" CACHE STRING "c compiler flags")
SET(CMAKE_CXX_FLAGS "${COMPILER_COMMON_FLAGS} -std=c++14" CACHE STRING "c++ compiler flags")
SET(CMAKE_ASM_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE}" CACHE STRING "assembler compiler flags")
SET(CMAKE_EXE_LINKER_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE} ${MCU_FPU_TYPE} -mlong-calls -Wl,--gc-sections  -specs=nosys.specs -specs=nano.specs -lgcc -lc" CACHE STRING "executable linker flags")
SET(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE} ${MCU_FPU_TYPE}" CACHE STRING "module linker flags")
SET(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE} ${MCU_FPU_TYPE}" CACHE STRING "shared linker flags")

#-- Debug flags ----------------------------------------------------------------
#SET(DEBUG_OPT "-Og")
SET(DEBUG_OPT "-O0")
SET(CMAKE_C_FLAGS_DEBUG "-g ${DEBUG_OPT} -DDEBUG" CACHE STRING "c compiler flags debug")
SET(CMAKE_CXX_FLAGS_DEBUG "-g ${DEBUG_OPT} -DDEBUG" CACHE STRING "c++ compiler flags debug")
SET(CMAKE_ASM_FLAGS_DEBUG "-g" CACHE STRING "assembler compiler flags debug")
SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE STRING "linker flags debug")

#-- Release flags ----------------------------------------------------------------
SET(CMAKE_C_FLAGS_RELEASE "-O2 " CACHE STRING "c compiler flags release")
SET(CMAKE_CXX_FLAGS_RELEASE "-O2" CACHE STRING "c++ compiler flags release")
SET(CMAKE_ASM_FLAGS_RELEASE "" CACHE STRING "assembler compiler flags release")
SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "" CACHE STRING "linker flags release")

#-- Release with debug info flags ----------------------------------------------------------------
SET(CMAKE_C_FLAGS_RELWITHDEBINFO "-g -O2" CACHE STRING "c compiler flags release with debug info")
SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-g -O2" CACHE STRING "c++ compiler flags release with debug info")
SET(CMAKE_ASM_FLAGS_RELWITHDEBINFO "" CACHE STRING "assembler compiler flags release with debug info")
SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "" CACHE STRING "linker flags release with debug info")

#-- Minimum size release flags ----------------------------------------------------------------
SET(CMAKE_C_FLAGS_MINSIZEREL "-Os -flto -ffat-lto-objects" CACHE STRING "c compiler flags minimum size release")
SET(CMAKE_CXX_FLAGS_MINSIZEREL "-Os -flto -ffat-lto-objects" CACHE STRING "c++ compiler flags minimum size release")
SET(CMAKE_ASM_FLAGS_MINSIZEREL "" CACHE STRING "assembler compiler flags minimum size release")
SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "-flto" CACHE STRING "linker flags minimum size release")
