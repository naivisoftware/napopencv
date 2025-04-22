set(opencv_tld ${NAP_ROOT}/modules/napopencv/thirdparty/opencv)
if(WIN32)
    set(opencv_dir ${opencv_tld}/msvc/x86_64)
elseif(APPLE)
    set(opencv_dir ${opencv_tld}/macos/x86_64)
elseif(UNIX)
    set(opencv_dir ${opencv_tld}/linux/${ARCH})
endif()

# Find OpenCV
if(NOT TARGET OpenCV)
    if(UNIX)
        find_package(OpenCV PATHS ${opencv_dir}/lib/cmake/opencv4 REQUIRED)
    else()
        find_package(OpenCV PATHS ${opencv_dir} REQUIRED)
    endif()
endif()

target_include_directories(${PROJECT_NAME} PUBLIC ${OpenCV_INCLUDE_DIRS})

target_link_libraries(${PROJECT_NAME} ${OpenCV_LIBS})

# Copy OpenCV DLLs over to Windows build directory (also caters for deployment into packaged app)
if(WIN32)
    get_target_property(__dll_dbg opencv_world IMPORTED_LOCATION_DEBUG)
    get_target_property(__dll_release opencv_world  IMPORTED_LOCATION_RELEASE)

    # Copy OpenCV debug / release DLL based on config
    add_custom_command(
        TARGET ${PROJECT_NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND}
                -E copy_if_different
                "$<$<CONFIG:debug>:${__dll_dbg}>$<$<CONFIG:release>:${__dll_release}>"
                $<TARGET_FILE_DIR:${PROJECT_NAME}>)

    # Copy FFmpeg for OpenCV
    file(GLOB CV_FFMPEG_DLLS ${opencv_dir}/x64/vc16/bin/opencv_videoio_ffmpeg*${CMAKE_SHARED_LIBRARY_SUFFIX}*)
    copy_files_to_bin(${CV_FFMPEG_DLLS})
endif()

# Install thirdparty into packaged app
if(NAP_BUILD_CONTEXT MATCHES "framework_release")
    # OpenCV
    if(UNIX)
        # Install library into packaged project
        file(GLOB OPENCV_DYLIBS ${opencv_dir}/lib/libopencv*${CMAKE_SHARED_LIBRARY_SUFFIX}*)
        install(FILES ${OPENCV_DYLIBS} DESTINATION lib)

        # Install licenses into packaged project
        install(DIRECTORY ${opencv_dir}/share/licenses DESTINATION licenses/opencv)
    else()
        # Install OpenCV license into packaged project
        install(FILES ${opencv_dir}/LICENSE DESTINATION licenses/opencv)
    endif()

    # FFmpeg libs on *nix
    list(APPEND CMAKE_MODULE_PATH ${NAP_ROOT}/system_modules/napvideo/thirdparty/cmake_find_modules)
    find_package(FFmpeg REQUIRED)
    set(ffmpeg_dir ${NAP_ROOT}/system_modules/napvideo/thirdparty/ffmpeg)
    if(UNIX)
        install(DIRECTORY ${FFMPEG_DIR}/lib/ DESTINATION lib)

        if(APPLE)
            # Add FFmpeg RPATH to built app on macOS
            macos_add_rpath_to_module_post_build(${PROJECT_NAME} $<TARGET_FILE:${PROJECT_NAME}> ${FFMPEG_DIR}/${NAP_THIRDPARTY_PLATFORM_DIR}/${ARCH}/lib)
        endif()
    endif()

    # Install FFmpeg license into packaged app
    install(FILES ${FFMPEG_LICENSE_DIR}/COPYING.LGPLv2.1
                  ${FFMPEG_LICENSE_DIR}/COPYING.LGPLv3
                  ${FFMPEG_LICENSE_DIR}/LICENSE.md
            DESTINATION licenses/FFmpeg
            )
    # Install FFmpeg source into packaged app to comply with license
    install(FILES ${FFMPEG_SOURCE_DIST} DESTINATION licenses/FFmpeg)
endif()
