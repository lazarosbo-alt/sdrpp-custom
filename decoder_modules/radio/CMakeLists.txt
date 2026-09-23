cmake_minimum_required(VERSION 3.13)
project(radio)

file(GLOB_RECURSE SRC "src/*.cpp")

include(${SDRPP_MODULE_CMAKE})

target_include_directories(radio PRIVATE "src/")

# Link FFTW3 for MPX analysis functionality
if (MSVC)
    # On Windows with vcpkg - comprehensive detection strategy
    set(FFTW3_FOUND FALSE)
    
    # Method 1: Try finding vcpkg package config
    find_package(fftw3 CONFIG QUIET)
    if (fftw3_FOUND)
        message(STATUS "Found fftw3 package via CONFIG")
        if (TARGET fftw3::fftw3f)
            target_link_libraries(radio PRIVATE fftw3::fftw3f)
            message(STATUS "Using FFTW3 target: fftw3::fftw3f")
            set(FFTW3_FOUND TRUE)
        elseif (TARGET fftw3::fftw3)
            target_link_libraries(radio PRIVATE fftw3::fftw3)
            message(STATUS "Using FFTW3 target: fftw3::fftw3")
            set(FFTW3_FOUND TRUE)
        endif()
    endif()
    
    # Method 2: Try alternative package names
    if (NOT FFTW3_FOUND)
        find_package(FFTW3 CONFIG QUIET)
        if (FFTW3_FOUND)
            message(STATUS "Found FFTW3 package via CONFIG")
            if (TARGET FFTW3::fftw3f)
                target_link_libraries(radio PRIVATE FFTW3::fftw3f)
                message(STATUS "Using FFTW3 target: FFTW3::fftw3f")
                set(FFTW3_FOUND TRUE)
            elseif (TARGET FFTW3::fftw3)
                target_link_libraries(radio PRIVATE FFTW3::fftw3)
                message(STATUS "Using FFTW3 target: FFTW3::fftw3")
                set(FFTW3_FOUND TRUE)
            endif()
        endif()
    endif()
    
    # Method 3: Direct library search in vcpkg paths
    if (NOT FFTW3_FOUND)
        find_library(FFTW3F_LIB NAMES fftw3f libfftw3f)
        find_path(FFTW3_INCLUDE_DIR fftw3.h)
        
        if (FFTW3F_LIB AND FFTW3_INCLUDE_DIR)
            target_include_directories(radio PRIVATE ${FFTW3_INCLUDE_DIR})
            target_link_libraries(radio PRIVATE ${FFTW3F_LIB})
            message(STATUS "Using FFTW3 library search: ${FFTW3F_LIB}")
            set(FFTW3_FOUND TRUE)
        endif()
    endif()
    
    # Method 4: Last resort - try PkgConfig even on Windows
    if (NOT FFTW3_FOUND)
        find_package(PkgConfig QUIET)
        if (PkgConfig_FOUND)
            pkg_check_modules(FFTW3F_PC QUIET fftw3f)
            if (FFTW3F_PC_FOUND)
                target_include_directories(radio PRIVATE ${FFTW3F_PC_INCLUDE_DIRS})
                target_link_directories(radio PRIVATE ${FFTW3F_PC_LIBRARY_DIRS})
                target_link_libraries(radio PRIVATE ${FFTW3F_PC_LIBRARIES})
                message(STATUS "Using FFTW3 via PkgConfig: ${FFTW3F_PC_LIBRARIES}")
                set(FFTW3_FOUND TRUE)
            endif()
        endif()
    endif()
    
    # Final status
    if (NOT FFTW3_FOUND)
        message(FATAL_ERROR "FFTW3 not found! MPX Analysis requires FFTW3. Please install via vcpkg: vcpkg install fftw3")
    endif()
elseif (ANDROID)
    # Android: Use alternative approach for MPX analysis
    # Try to find FFTW3 in Android NDK or use Kiss FFT as fallback
    find_library(FFTW3F_LIBRARY NAMES fftw3f libfftw3f)
    find_path(FFTW3F_INCLUDE_DIR fftw3.h 
        PATHS 
        ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include
        ${CMAKE_SYSROOT}/usr/include
    )
    
    if(FFTW3F_LIBRARY AND FFTW3F_INCLUDE_DIR)
        target_include_directories(radio PRIVATE ${FFTW3F_INCLUDE_DIR})
        target_link_libraries(radio PRIVATE ${FFTW3F_LIBRARY})
        message(STATUS "Found FFTW3F for Android: ${FFTW3F_LIBRARY}")
    else()
        # Use Kiss FFT as fallback for Android MPX analysis
        message(STATUS "FFTW3 not found on Android, using Kiss FFT fallback")
        target_compile_definitions(radio PRIVATE USE_KISS_FFT_FOR_MPX)
    endif()
else()
    # On Linux/macOS, use pkg-config
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(FFTW3F REQUIRED fftw3f)

    target_include_directories(radio PRIVATE ${FFTW3F_INCLUDE_DIRS})
    target_link_directories(radio PRIVATE ${FFTW3F_LIBRARY_DIRS})
    target_link_libraries(radio PRIVATE ${FFTW3F_LIBRARIES})
endif()