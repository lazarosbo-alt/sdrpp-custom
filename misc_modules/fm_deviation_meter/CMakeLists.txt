cmake_minimum_required(VERSION 3.13)
project(fm_deviation_meter)

add_library(fm_deviation_meter SHARED src/main.cpp)
target_link_libraries(fm_deviation_meter sdrpp_core)

# Ενεργοποίηση C++17 για τον MSVC ώστε να αναγνωριστούν τα namespaces και η κλάση Module
set_property(TARGET fm_deviation_meter PROPERTY CXX_STANDARD 17)
set_property(TARGET fm_deviation_meter PROPERTY CXX_STANDARD_REQUIRED ON)

if (MSVC)
    target_compile_options(fm_deviation_meter PRIVATE /std:c++17 /EHsc)
endif()
