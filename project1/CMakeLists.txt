
cmake_minimum_required(VERSION 3.8)
project(cminus_compiler)

# cmake modules path
set(CMAKE_MODULE_PATH
    ${CMAKE_MODULE_PATH} ${PROJECT_SOURCE_DIR}/cmake)

find_package(FLEX)
flex_target(LEXER cminus.lex lex.yy.c)

# project source files
set(SOURCE_DIR ${PROJECT_SOURCE_DIR})
set(SOURCE_FILES
    ${SOURCE_DIR}/main.c
    ${SOURCE_DIR}/util.c
    ${FLEX_LEXER_OUTPUTS})

message("[ Source files for ${PROJECT_NAME} ]")
foreach(SOURCE_FILE ${SOURCE_FILES})
    message(STATUS "${SOURCE_FILE}")
endforeach()

add_executable(${PROJECT_NAME} ${SOURCE_FILES})

# Build options
set(BUILD_FLAGS "-g -O3 -Wall -Wextra -Wpedantic")
message("flags = ${BUILD_FLAGS}")
set_target_properties(${PROJECT_NAME}
    PROPERTIES
    COMPILE_FLAGS "${BUILD_FLAGS}")

target_link_libraries(${PROJECT_NAME}
    ${FLEX_LIBRARIES})
