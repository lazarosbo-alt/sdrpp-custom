cmake_minimum_required(VERSION 3.13)
project(fm_deviation_meter)

# Ενσωμάτωση του επίσημου template για τα modules του SDR++
include(${SDRPP_MODULE_CMAKE})

# Δημιουργία του module με την εντολή που αναγνωρίζει το SDR++
add_sdrpp_module(fm_deviation_meter
    src/main.cpp
)

target_link_libraries(fm_deviation_meter PRIVATE sdrpp_core)

# Διασφάλιση προτύπου C++17 για τον MSVC
set_property(TARGET fm_deviation_meter PROPERTY CXX_STANDARD 17)
set_property(TARGET fm_deviation_meter PROPERTY CXX_STANDARD_REQUIRED ON)

if (MSVC)
    target_compile_options(fm_deviation_meter PRIVATE /std:c++17 /EHsc)
endif()
