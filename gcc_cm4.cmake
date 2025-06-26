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
SET(MCU_FPU_TYPE "-mfloat-abi=soft")

#-- Common flags ---------------------------------------------------------------
SET(COMPILER_COMMON_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE} ${MCU_FPU_TYPE}")
SET(CMAKE_C_FLAGS "${COMPILER_COMMON_FLAGS} -std=gnu11" CACHE STRING "c compiler flags")
SET(CMAKE_CXX_FLAGS "${COMPILER_COMMON_FLAGS} -std=c++14" CACHE STRING "c++ compiler flags")
SET(CMAKE_ASM_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE}" CACHE STRING "assembler compiler flags")
SET(CMAKE_EXE_LINKER_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE} ${MCU_FPU_TYPE} -mlong-calls -Wl,--gc-sections -Wl,--cref  -specs=nosys.specs -specs=nano.specs -lgcc -lc -fno-exceptions" CACHE STRING "executable linker flags")
SET(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE} ${MCU_FPU_TYPE} -fno-exceptions" CACHE STRING "module linker flags")
SET(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=${MCU_CORE_TYPE} ${MCU_FPU_TYPE} -fno-exceptions" CACHE STRING "shared linker flags")

#-- Debug flags ----------------------------------------------------------------
SET(CMAKE_C_FLAGS_DEBUG "-g -DDEBUG" CACHE STRING "c compiler flags debug")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -DDEBUG" CACHE STRING "c++ compiler flags debug")
SET(CMAKE_ASM_FLAGS_DEBUG "-g" CACHE STRING "assembler compiler flags debug")
SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE STRING "linker flags debug")

#-- Release flags ----------------------------------------------------------------
SET(CMAKE_C_FLAGS_RELEASE "-DNDEBUG" CACHE STRING "c compiler flags release")
SET(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG" CACHE STRING "c++ compiler flags release")
SET(CMAKE_ASM_FLAGS_RELEASE "" CACHE STRING "assembler compiler flags release")
SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "" CACHE STRING "linker flags release")

#-- Release with debug info flags ----------------------------------------------------------------
SET(CMAKE_C_FLAGS_RELWITHDEBINFO "-g -DNDEBUG" CACHE STRING "c compiler flags release with debug info")
SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-g -DNDEBUG" CACHE STRING "c++ compiler flags release with debug info")
SET(CMAKE_ASM_FLAGS_RELWITHDEBINFO "" CACHE STRING "assembler compiler flags release with debug info")
SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "" CACHE STRING "linker flags release with debug info")

#-- Minimum size release flags ----------------------------------------------------------------
SET(CMAKE_C_FLAGS_MINSIZEREL "-flto -ffat-lto-objects -DNDEBUG" CACHE STRING "c compiler flags minimum size release")
SET(CMAKE_CXX_FLAGS_MINSIZEREL "-flto -ffat-lto-objects -DNDEBUG" CACHE STRING "c++ compiler flags minimum size release")
SET(CMAKE_ASM_FLAGS_MINSIZEREL "" CACHE STRING "assembler compiler flags minimum size release")
SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "-flto" CACHE STRING "linker flags minimum size release")


#set(CMAKE_EXECUTABLE_SUFFIX_C   .elf)
#set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)
#set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)

# This should be safe to set for a bare-metal cross-compiler
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)


# This function adds a target with name '${TARGET}_always_display_size'. The new
# target builds a TARGET and then calls the program defined in CMAKE_SIZE to
# display the size of the final ELF.
#function(arm_print_size_of_target TARGET)
#    add_custom_target(${TARGET}_always_display_size
#        ALL COMMAND ${CMAKE_SIZE} "$<TARGET_FILE:${TARGET}>"
#        COMMENT "Target Sizes: "
#        DEPENDS ${TARGET}
#    )
#endfunction()


# This function calls the objcopy program defined in CMAKE_OBJCOPY to generate
# file with object format specified in OBJCOPY_BFD_OUTPUT.
# The generated file has the name of the target output but with extension
# corresponding to the OUTPUT_EXTENSION argument value.
# The generated file will be placed in the same directory as the target output file.
#function(_arm_generate_file TARGET OUTPUT_EXTENSION OBJCOPY_BFD_OUTPUT)
#    get_target_property(TARGET_OUTPUT_NAME ${TARGET} OUTPUT_NAME)
#    if (TARGET_OUTPUT_NAME)
#        set(OUTPUT_FILE_NAME "${TARGET_OUTPUT_NAME}.${OUTPUT_EXTENSION}")
#    else()
#        set(OUTPUT_FILE_NAME "${TARGET}.${OUTPUT_EXTENSION}")
#    endif()

#    get_target_property(RUNTIME_OUTPUT_DIRECTORY ${TARGET} RUNTIME_OUTPUT_DIRECTORY)
#    if(RUNTIME_OUTPUT_DIRECTORY)
#        set(OUTPUT_FILE_PATH "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_FILE_NAME}")
#    else()
#        set(OUTPUT_FILE_PATH "${OUTPUT_FILE_NAME}")
#    endif()

#    add_custom_command(
#        TARGET ${TARGET}
#        POST_BUILD
#        COMMAND ${CMAKE_OBJCOPY} -O ${OBJCOPY_BFD_OUTPUT} "$<TARGET_FILE:${TARGET}>" ${OUTPUT_FILE_PATH}
#        BYPRODUCTS ${OUTPUT_FILE_PATH}
#        COMMENT "Generating ${OBJCOPY_BFD_OUTPUT} file ${OUTPUT_FILE_NAME}"
#    )
#endfunction()

## This function adds post-build generation of the binary file from the target ELF.
## The generated file will be placed in the same directory as the ELF file.
#function(arm_generate_binary_file TARGET)
#    _arm_generate_file(${TARGET} "bin" "binary")
#endfunction()

## This function adds post-build generation of the Motorola S-record file from the target ELF.
## The generated file will be placed in the same directory as the ELF file.
#function(arm_generate_srec_file TARGET)
#    _arm_generate_file(${TARGET} "srec" "srec")
#endfunction()

## This function adds post-build generation of the Intel hex file from the target ELF.
## The generated file will be placed in the same directory as the ELF file.
#function(arm_generate_hex_file TARGET)
#    _arm_generate_file(${TARGET} "hex" "ihex")
#endfunction()

#function(arm_add_linker_script TARGET VISIBILITY SCRIPT)
#    get_filename_component(SCRIPT "${SCRIPT}" ABSOLUTE)
#    target_link_options(${TARGET} ${VISIBILITY} -T "${SCRIPT}")

#    get_target_property(TARGET_TYPE ${TARGET} TYPE)
#    if(TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
#        set(INTERFACE_PREFIX "INTERFACE_")
#    endif()

#    get_target_property(LINK_DEPENDS ${TARGET} ${INTERFACE_PREFIX}LINK_DEPENDS)
#    if(LINK_DEPENDS)
#        list(APPEND LINK_DEPENDS "${SCRIPT}")
#    else()
#        set(LINK_DEPENDS "${SCRIPT}")
#    endif()


#    set_target_properties(${TARGET} PROPERTIES ${INTERFACE_PREFIX}LINK_DEPENDS "${LINK_DEPENDS}")
#endfunction()
