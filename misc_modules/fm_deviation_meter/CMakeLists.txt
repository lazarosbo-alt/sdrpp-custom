cmake_minimum_required(VERSION 3.10)
project(fm_deviation_meter)

add_library(fm_deviation_meter SHARED src/main.cpp)
target_link_libraries(fm_deviation_meter sdrpp_core)
