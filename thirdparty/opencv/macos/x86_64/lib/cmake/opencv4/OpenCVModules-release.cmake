#----------------------------------------------------------------
# Generated CMake target import file for configuration "RELEASE".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "opencv_world" for configuration "RELEASE"
set_property(TARGET opencv_world APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(opencv_world PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libopencv_world.4.1.2.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libopencv_world.4.1.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS opencv_world )
list(APPEND _IMPORT_CHECK_FILES_FOR_opencv_world "${_IMPORT_PREFIX}/lib/libopencv_world.4.1.2.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
