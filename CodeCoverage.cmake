
# find llvm spesific tools
find_program(LLVM_COV_PATH NAMES llvm-cov llvm-cov.exe)
find_program(LLVM_PROFDATA_PATH NAMES llvm-profdata llvm-profdata.exe)

# find standart coverage tools
find_program(GCOV_PATH NAMES gcov gcov.exe )
find_program(GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/scripts/test)
find_program(LCOV_PATH NAMES lcov lcov.bat lcov.exe lcov.perl)

find_program(CPPFILT_PATH NAMES c++filt)

# --gcov-executable param for working Clang and GCC with GCOVR
set(GCOV_EXECUTABLE)

# coverage reports folder
set(REPORTS_PATH
    ${CMAKE_BINARY_DIR}/coverage_reports
)
# html report folder
set(HTML_REPORT_PATH
    ${REPORTS_PATH}/html_report
)

# coverage using GCOVR (can be used with Clang and GCC)
function(setup_target_for_coverage_gcovr)

    set(options HTML COBERTURA SONARQUBE COVERALLS)
    set(oneValueArgs BASE_DIRECTORY NAME TARGET)
    set(multiValueArgs EXCLUDE EXECUTABLE EXECUTABLE_ARGS DEPENDENCIES LCOV_ARGS GENHTML_ARGS)
    cmake_parse_arguments(COVERAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT GCOVR_PATH)
        message(FATAL_ERROR "gcovr not fount! Aborting...")
    endif()

    if (NOT GCOV_EXECUTABLE)
        message(FATAL_ERROR "coverage flags have not been set! Aborting...")
    endif()

    get_filename_component(BASEDIR ${CMAKE_CURRENT_LIST_DIR}/../ ABSOLUTE)

#============================== SETS ====================================

    # run tests
    set(EXEC_TEST
        ${COVERAGE_EXECUTABLE} ${COVERAGE_EXECUTABLE_ARGS}
    )


    set(DEFAULT_CORV_SETTINGS
        --exclude-unreachable-branches
        --print-summary
        --root ${BASEDIR}
        ${GCOVR_ADDITIONAL_ARGS} ${GCOVR_EXCLUDE_ARGS}
        --object-directory=${PROJECT_BINARY_DIR}
    )

    set(CREATE_DIRS
        COMMAND ${CMAKE_COMMAND} -E make_directory ${REPORTS_PATH}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${HTML_REPORT_PATH}
    )

#============================== HTML_COVR ====================================

    if (${COVERAGE_HTML})
        set(HTML_COVR
            ${GCOVR_PATH}
            --gcov-executable ${GCOV_EXECUTABLE}
            --html-details
            -o ${HTML_REPORT_PATH}/${COVERAGE_NAME}_html.html
            ${DEFAULT_CORV_SETTINGS}
        )
    endif()

#============================== COBERTURA_COVR ====================================

    if (${COVERAGE_COBERTURA})

        set(COBERTURA_COVR
            ${GCOVR_PATH}
            --gcov-executable ${GCOV_EXECUTABLE}
            --xml-pretty
            -o ${REPORTS_PATH}/${COVERAGE_NAME}_cobertura.xml
            ${DEFAULT_CORV_SETTINGS}
        )

    endif()

#============================== SONARQUBE_COVR ====================================

    if (${COVERAGE_SONARQUBE})

        set(SONARQUBE_COVR
            ${GCOVR_PATH}
            --gcov-executable ${GCOV_EXECUTABLE}
            --sonarqube
            -o ${REPORTS_PATH}/${COVERAGE_NAME}_sonarqube.xml
            ${DEFAULT_CORV_SETTINGS}
        )

    endif()

#============================== COVERALLS_COVR ====================================

    if (${COVERAGE_COVERALLS})

         set(COVERALLS_COVR
            ${GCOVR_PATH}
            --gcov-executable ${GCOV_EXECUTABLE}
            --coveralls-pretty
            -o ${REPORTS_PATH}/${COVERAGE_NAME}_coveralls.json
            ${DEFAULT_CORV_SETTINGS}
        )


    endif()

    add_custom_target(${COVERAGE_NAME}
        COMMAND ${EXEC_TEST}
        ${CREATE_DIRS}
        COMMAND ${HTML_COVR}
        COMMAND ${COBERTURA_COVR}
        COMMAND ${SONARQUBE_COVR}
        COMMAND ${COVERALLS_COVR}
        DEPENDS ${COVERAGE_DEPENDENCIES}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        VERBATIM
        COMMENT "Running tests"
    )



endfunction()

# coverage using LLVM_COV (can be used only with Clang)
function(setup_target_for_coverage_llvm)

    set(options HTML LCOV COBERTURA)
    set(oneValueArgs BASE_DIRECTORY NAME TARGET)
    set(multiValueArgs EXECUTABLE EXECUTABLE_ARGS DEPENDENCIES SOURCES)
    cmake_parse_arguments(COVERAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # if (NOT ${LLVM_COV_PATH})
    #     message(FATAL_ERROR "llvm_cov not found. Aborting...")
    # endif()
    #
    # if (NOT GCOV_EXECUTABLE)
    #     message(FATAL_ERROR "coverage flags have not been set! Aborting...")
    # endif()


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

    else()
        message(FATAL_ERROR "You cannot use llvm_cov using a non-Clang compiler")
    endif()

endfunction()


function(target_append_coverage_flags)

    set(options GCOVR LLVM)
    set(oneValueArgs TARGET)
    set(multiValueArgs "")
    cmake_parse_arguments(COVERAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

#     Set compiler flags

    if (${COVERAGE_GCOVR} AND ${COVERAGE_LLVM})
        message(FATAL_ERROR "Only one of GCOVR or LLVM may be specified at a time")
    elseif(${COVERAGE_GCOVR})
        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            set(COVERAGE_COMPILER_FLAGS "-g --coverage" CACHE INTERNAL "")
            set(COVERAGE_LINKER_FLAGS "-g --coverage" CACHE INTERNAL "")
            set(GCOV_EXECUTABLE ${GCOV_PATH} PARENT_SCOPE)
        elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
            set(COVERAGE_COMPILER_FLAGS "--coverage" CACHE INTERNAL "")
            set(COVERAGE_LINKER_FLAGS "--coverage" CACHE INTERNAL "")
            set(GCOV_EXECUTABLE "llvm-cov gcov" PARENT_SCOPE)
        endif()
#       Link lib GCOV
        link_libraries(gcov)
        target_link_libraries(${COVERAGE_TARGET} PRIVATE gcov)
    elseif(${COVERAGE_LLVM})
        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            message(FATAL_ERROR "Can't use LLVM while using GNU")
        elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
            set(COVERAGE_COMPILER_FLAGS "-fprofile-instr-generate -fcoverage-mapping" CACHE INTERNAL "")
            set(COVERAGE_LINKER_FLAGS "-fprofile-instr-generate -fcoverage-mapping" CACHE INTERNAL "")
        endif()
    else()
        message(FATAL_ERROR "At least one of GCOVR or LLVM may be specified at a time")
    endif()


    separate_arguments(_compiler_flags_list NATIVE_COMMAND "${COVERAGE_COMPILER_FLAGS}")
    separate_arguments(_linker_flags_list NATIVE_COMMAND "${COVERAGE_LINKER_FLAGS}")

    target_compile_options(${COVERAGE_TARGET} PRIVATE ${_compiler_flags_list})
    target_link_options(${COVERAGE_TARGET} PRIVATE ${_linker_flags_list})


endfunction()


function(append_coverage_flags)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COVERAGE_COMPILER_FLAGS}" PARENT_SCOPE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COVERAGE_COMPILER_FLAGS}" PARENT_SCOPE)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${COVERAGE_LINKER_FLAGS}")
endfunction()


