cmake_minimum_required(VERSION 3.13)
project(m17_decoder)

file(GLOB_RECURSE SRC "src/*.cpp" "src/*.c")

include(${SDRPP_MODULE_CMAKE})

target_include_directories(m17_decoder PRIVATE "src/")

if (MSVC)
    # Lib path
    target_include_directories(m17_decoder PRIVATE "C:/Program Files/codec2/include/")
    target_link_directories(m17_decoder PRIVATE "C:/Program Files/codec2/lib")

    target_link_libraries(m17_decoder PRIVATE libcodec2)
elseif (ANDROID)
    target_include_directories(m17_decoder PUBLIC
        /sdr-kit/${ANDROID_ABI}/include/codec2
    )

    target_link_libraries(m17_decoder PUBLIC
        /sdr-kit/${ANDROID_ABI}/lib/libcodec2.so
    )
else ()
    find_package(PkgConfig)

    pkg_check_modules(LIBCODEC2 REQUIRED codec2)

    target_include_directories(m17_decoder PRIVATE ${LIBCODEC2_INCLUDE_DIRS})
    target_link_directories(m17_decoder PRIVATE ${LIBCODEC2_LIBRARY_DIRS})
    target_link_libraries(m17_decoder PRIVATE ${LIBCODEC2_LIBRARIES})

    # Fix for ARM Homebrew paths and codec2 include issue
    if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        # Check if we're on ARM (Apple Silicon)
        if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64")
            # ARM Homebrew path
            target_include_directories(m17_decoder PRIVATE "/opt/homebrew/include")
            # Fix for codec2 include path bug - add the codec2 subdirectory
            target_include_directories(m17_decoder PRIVATE "/opt/homebrew/include/codec2")
        else ()
            # Intel Homebrew path
            target_include_directories(m17_decoder PRIVATE "/usr/local/include")
        endif()
    endif()
endif ()