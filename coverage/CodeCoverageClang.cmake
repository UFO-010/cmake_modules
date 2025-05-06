
# find llvm spesific tools
find_program(LLVM_COV_PATH NAMES llvm-cov llvm-cov.exe)
find_program(LLVM_PROFDATA_PATH NAMES llvm-profdata llvm-profdata.exe)

# find standart coverage tools
find_program(GCOV_PATH NAMES gcov gcov.exe )
find_program(GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/scripts/test)
find_program(LCOV_PATH NAMES lcov lcov.bat lcov.exe lcov.perl)
find_program(GENHTML_PATH NAMES genhtml genhtml.perl genhtml.bat)

# find local python script to convert lcov report to cobertura.xml, necessary only with llvm-cov
find_file(COBERTURA_PY_PATH lcov_cobertura.py ${CMAKE_MODULE_PATH} NO_DEFAULT_PATH)

find_program(CPPFILT_PATH NAMES c++filt)


# set Clang specific coverage flags to use with llvm-cov
if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(COVERAGE_COMPILER_FLAGS "-fprofile-instr-generate -fcoverage-mapping" CACHE INTERNAL "")
    set(COVERAGE_LINKER_FLAGS "-fprofile-instr-generate" CACHE INTERNAL "")
endif()


# set GNU specific coverage flags to use with gcov (can be also set to use with llvm-cov in gcov mode)
# llvm-cov gcov can be used with lcov, run --gcov-tool llvm-cov --gcov-tool gcov
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(COVERAGE_COMPILER_FLAGS "-g --coverage" CACHE INTERNAL "")
    set(COVERAGE_LINKER_FLAGS "-g --coverage" CACHE INTERNAL "")
    link_libraries(gcov)
endif()


function(setup_target_for_coverage_gcovr)

    set(options HTML SONARQUBE CLOVER JACOCO COVERALLS)
    set(oneValueArgs BASE_DIRECTORY NAME)
    set(multiValueArgs EXCLUDE EXECUTABLE EXECUTABLE_ARGS DEPENDENCIES)
    cmake_parse_arguments(COVERAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Set base directory (as absolute path), or default to PROJECT_SOURCE_DIR
    if(DEFINED COVERAGE_BASE_DIRECTORY)
        get_filename_component(BASEDIR ${COVERAGE_BASE_DIRECTORY} ABSOLUTE)
    else()
        set(BASEDIR ${PROJECT_SOURCE_DIR})
    endif()

    # Collect excludes (CMake 3.4+: Also compute absolute paths)
    set(GCOVR_EXCLUDES "")
    foreach(EXCLUDE ${COVERAGE_EXCLUDE} ${COVERAGE_EXCLUDES} ${COVERAGE_GCOVR_EXCLUDES})
        if(CMAKE_VERSION VERSION_GREATER 3.4)
            get_filename_component(EXCLUDE ${EXCLUDE} ABSOLUTE BASE_DIR ${BASEDIR})
        endif()
        list(APPEND GCOVR_EXCLUDES "${EXCLUDE}")
    endforeach()
    list(REMOVE_DUPLICATES GCOVR_EXCLUDES)

    # Combine excludes to several -e arguments
    set(GCOVR_EXCLUDE_ARGS "")
    foreach(EXCLUDE ${GCOVR_EXCLUDES})
        list(APPEND GCOVR_EXCLUDE_ARGS "-e")
        list(APPEND GCOVR_EXCLUDE_ARGS "${EXCLUDE}")
    endforeach()

    # Set up commands which will be run to generate coverage data
    # Run tests
    set(EXEC_TESTS
        ${COVERAGE_EXECUTABLE} ${COVERAGE_EXECUTABLE_ARGS}
    )
    # Create folder
    set(CREATE_FOLDER
        ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/${Coverage_NAME}
    )
    # Generate HTML report
    if(COVERAGE_HTML)
        set(GEN_REPORT_HTML
            COMMAND ${GCOVR_PATH} --html ${COVERAGE_NAME}/index.html --html-details -r ${BASEDIR} ${GCOVR_ADDITIONAL_ARGS}
            ${GCOVR_EXCLUDE_ARGS} --object-directory=${PROJECT_BINARY_DIR}
        )
    endif()

    if(COVERAGE_SONARQUBE)

    endif()

    if(COVERAGE_CLOVER)

    endif()

    if(COVERAGE_JACOCO)

    endif()

    if(COVERAGE_COVERALLS)

    endif()

    add_custom_target(${Coverage_NAME}
        COMMAND ${EXEC_TESTS}
        COMMAND ${CREATE_FOLDER}
        ${GEN_REPORT_HTML}

        BYPRODUCTS ${PROJECT_BINARY_DIR}/${COVERAGE_NAME}/index.html  # report directory
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        DEPENDS ${COVERAGE_DEPENDENCIES}
        VERBATIM # Protect arguments to commands
        COMMENT "Running gcovr to produce HTML code coverage report."
    )

endfunction()


function(setup_target_for_coverage_llvm)

    set(options HTML LCOV COBERTURA)
    set(oneValueArgs BASE_DIRECTORY NAME TARGET)
    set(multiValueArgs EXECUTABLE EXECUTABLE_ARGS DEPENDENCIES SOURCES)
    cmake_parse_arguments(COVERAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(PROFRAW_FORMAT "${CMAKE_BINARY_DIR}/${COVERAGE_NAME}.profraw")
        set(PROFDATA_FILE "${CMAKE_BINARY_DIR}/${COVERAGE_NAME}.profdata")

        # run tests
        set(EXEC_TEST
            ${COVERAGE_EXECUTABLE} ${COVERAGE_EXECUTABLE_ARGS}
        )
        # set profile and run test executable
        set(SET_PROFILE
            LLVM_PROFILE_FILE=${PROFRAW_FORMAT} ./${COVERAGE_TARGET}
        )
        # generate llvm coverage
        set(GEN_PROFDATA
            ${LLVM_PROFDATA_PATH} merge -sparse ${PROFRAW_FORMAT}
            -output=${PROFDATA_FILE}
        )
        # generate report and write summarized info to text file
        set(GEN_REPORT
            ${LLVM_COV_PATH} show --use-color=false --format=text --output-dir=${COVERAGE_NAME}
            --instr-profile=${PROFDATA_FILE} ${COVERAGE_TARGET} ${COVERAGE_SOURCES}
        )
        # if HTML option is set, generate HTML report with sources
        if(COVERAGE_HTML)
            set(GEN_REPORT_HTML
                COMMAND ${LLVM_COV_PATH} show --output-dir=${COVERAGE_NAME} --format=html
                --instr-profile=${PROFDATA_FILE} ${COVERAGE_TARGET} ${COVERAGE_SOURCES}
            )
        endif()
        # show report in cmd
        set(SHOW_REPORT_CMD
            ${LLVM_COV_PATH} report --instr-profile=${PROFDATA_FILE} ${COVERAGE_TARGET} ${COVERAGE_SOURCES}
        )

        add_custom_target(${COVERAGE_NAME}
            COMMAND ${EXEC_TEST}
            COMMAND ${SET_PROFILE}
            COMMAND ${GEN_PROFDATA}
            COMMAND ${GEN_REPORT}
            COMMAND ${SHOW_REPORT_CMD}
            ${GEN_REPORT_HTML}
            DEPENDS ${COVERAGE_DEPENDENCIES}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM
            COMMENT "Running tests"
        )

    endif()

endfunction()


function(setup_target_for_coverage_llvm_lcov)

    set(options COBERTURA)
    set(oneValueArgs BASE_DIRECTORY NAME TARGET)
    set(multiValueArgs EXCLUDE EXECUTABLE EXECUTABLE_ARGS DEPENDENCIES SOURCES)
    cmake_parse_arguments(COVERAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")

        set(PROFRAW_FORMAT "${CMAKE_BINARY_DIR}/${COVERAGE_NAME}.profraw")
        set(PROFDATA_FILE "${CMAKE_BINARY_DIR}/${COVERAGE_NAME}.profdata")

        get_filename_component(BASEDIR ${CMAKE_CURRENT_LIST_DIR}/../ ABSOLUTE)

        # run tests
        set(EXEC_TEST
            ${COVERAGE_EXECUTABLE} ${COVERAGE_EXECUTABLE_ARGS}
        )
        # set profile and run test executable
        set(SET_PROFILE
            LLVM_PROFILE_FILE=${PROFRAW_FORMAT} ./${COVERAGE_TARGET}
        )
        # generate llvm coverage
        set(GEN_PROFDATA
            ${LLVM_PROFDATA_PATH} merge --sparse ${PROFRAW_FORMAT}
            --output=${PROFDATA_FILE}
        )
        # generate lcov report
        set(GEN_LCOV_REPORT
            COMMAND ${LLVM_COV_PATH} export --instr-profile=${PROFDATA_FILE} --format=lcov
            ${COVERAGE_TARGET} ${COVERAGE_SOURCES} > ${CMAKE_BINARY_DIR}/${COVERAGE_NAME}_lcov.info
        )
        # if COBERTURA option is set, generate cobertura report
        if(COVERAGE_COBERTURA)
            set(GEN_XML_REPORT
                COMMAND python3 ${COBERTURA_PY_PATH} ${CMAKE_BINARY_DIR}/${COVERAGE_NAME}_lcov.info
                --base-dir ${CMAKE_SOURCE_DIR} -o ${CMAKE_BINARY_DIR}/${COVERAGE_NAME}_cobertura.xml
            )
        endif()

        add_custom_target(${COVERAGE_NAME}
            COMMAND ${EXEC_TEST}
            COMMAND ${SET_PROFILE}
            COMMAND ${GEN_PROFDATA}
            ${GEN_LCOV_REPORT}
            ${GEN_XML_REPORT}
            DEPENDS ${COVERAGE_DEPENDENCIES}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            VERBATIM
            COMMENT "Running tests"
        )

    endif()

endfunction()


function(target_append_coverage_flags target)

    separate_arguments(_compiler_flags_list NATIVE_COMMAND "${COVERAGE_COMPILER_FLAGS}")
    separate_arguments(_linker_flags_list NATIVE_COMMAND "${COVERAGE_LINKER_FLAGS}")

    target_compile_options(${target} PRIVATE ${_compiler_flags_list})
    target_link_options(${target} PRIVATE ${_linker_flags_list})

    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_link_libraries(${target} PRIVATE gcov)
    endif()

endfunction()


function(append_coverage_flags)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COVERAGE_COMPILER_FLAGS}" PARENT_SCOPE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COVERAGE_COMPILER_FLAGS}" PARENT_SCOPE)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${COVERAGE_LINKER_FLAGS}")
endfunction()


