cmake_minimum_required(VERSION 3.10)
project(fm_deviation_meter)

# Βρες τις εξωτερικές βιβλιοθήκες μέσω vcpkg
find_package(volk REQUIRED CONFIG)
find_package(glfw3 REQUIRED)

# Δημιούργησε το dll
add_library(fm_deviation_meter SHARED main.cpp src/main.cpp)

# Βάλε εδώ τα include paths (και του module, και του πυρήνα της SDR++)
target_include_directories(fm_deviation_meter PRIVATE
    src
    ../../core/src
)

# Σύνδεσε με volk και glfw3 (δεν χρειαζόμαστε το sdrpp_core εδώ)
target_link_libraries(fm_deviation_meter PRIVATE volk::volk glfw)

# Οι ορισμοί που απαιτεί η SDR++ για τα modules
target_compile_definitions(fm_deviation_meter PRIVATE -D_WINDLL)
