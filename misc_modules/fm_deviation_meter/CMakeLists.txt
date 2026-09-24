cmake_minimum_required(VERSION 3.13)
project(fm_deviation_meter)

add_library(fm_deviation_meter SHARED src/main.cpp)
target_link_libraries(fm_deviation_meter PRIVATE sdrpp_core)

# Σωστή διαδρομή προς τα headers του core για να βρεθούν τα module.h, json.hpp κλπ.
target_include_directories(fm_deviation_meter PRIVATE 
    ${CMAKE_SOURCE_DIR}/core/src
)

# Ενεργοποίηση C++17 για τον MSVC
set_property(TARGET fm_deviation_meter PROPERTY CXX_STANDARD 17)
set_property(TARGET fm_deviation_meter PROPERTY CXX_STANDARD_REQUIRED ON)

if (MSVC)
    target_compile_options(fm_deviation_meter PRIVATE /std:c++17 /EHsc)
endif()
