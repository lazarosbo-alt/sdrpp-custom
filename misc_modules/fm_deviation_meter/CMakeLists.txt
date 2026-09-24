cmake_minimum_required(VERSION 3.13)
project(fm_deviation_meter)

add_library(fm_deviation_meter SHARED src/main.cpp)
target_link_libraries(fm_deviation_meter PRIVATE sdrpp_core)

# Χρήση της επίσημης μεταβλητής του SDR++ για τα core headers
target_include_directories(fm_deviation_meter PRIVATE 
    ${SDRPP_CORE_ROOT}
    ${SDRPP_CORE_ROOT}/imgui
)

# Διασφάλιση προτύπου C++17 για τον MSVC
set_property(TARGET fm_deviation_meter PROPERTY CXX_STANDARD 17)
set_property(TARGET fm_deviation_meter PROPERTY CXX_STANDARD_REQUIRED ON)

if (MSVC)
    target_compile_options(fm_deviation_meter PRIVATE /std:c++17 /EHsc)
endif()
