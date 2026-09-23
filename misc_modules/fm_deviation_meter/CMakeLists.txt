cmake_minimum_required(VERSION 3.13)
project(fm_deviation_meter)

add_library(fm_deviation_meter MODULE
    src/main.cpp
)

target_link_libraries(fm_deviation_meter PRIVATE sdrpp_core)
target_include_directories(fm_deviation_meter PRIVATE src)

set_target_properties(fm_deviation_meter PROPERTIES
    PREFIX ""
    SUFFIX ".dll"
)

install(TARGETS fm_deviation_meter DESTINATION modules)