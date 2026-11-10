cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
project(tensorrt_ros)

find_package(ament_cmake REQUIRED)

# The package version is the TensorRT version that gets downloaded
ament_package_xml()
set(${PROJECT_NAME}_TENSORRT_BUILD "11")
set(${PROJECT_NAME}_CUDA_MAX_VERSION "12.9")

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux" OR NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
  message(FATAL_ERROR "The TensorRT binary archive requires Linux x86_64")
endif()

include(CheckLanguage)
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
  enable_language(CUDA)
  message(STATUS "Compiling with CUDA")
  set(${PROJECT_NAME}_CUDA_ENABLED TRUE)
else()
  message(STATUS "Compiling without CUDA")
  set(${PROJECT_NAME}_CUDA_ENABLED FALSE)
endif()

set(${PROJECT_NAME}_URL_BASE
  "https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/${${PROJECT_NAME}_VERSION}/tars")
set(${PROJECT_NAME}_ARCHIVE_NAME
  "TensorRT-${${PROJECT_NAME}_VERSION}.${${PROJECT_NAME}_TENSORRT_BUILD}.Linux.x86_64-gnu.cuda-${${PROJECT_NAME}_CUDA_MAX_VERSION}.tar.gz")
set(${PROJECT_NAME}_URL "${${PROJECT_NAME}_URL_BASE}/${${PROJECT_NAME}_ARCHIVE_NAME}")

set(${PROJECT_NAME}_EP_NAME "EP_${PROJECT_NAME}")
set(${PROJECT_NAME}_ARCHIVE_DIR
  "${CMAKE_CURRENT_BINARY_DIR}/${${PROJECT_NAME}_EP_NAME}-prefix/src/${${PROJECT_NAME}_EP_NAME}")

include(ExternalProject)
externalproject_add(${${PROJECT_NAME}_EP_NAME}
  URL "${${PROJECT_NAME}_URL}"
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  DOWNLOAD_NO_PROGRESS TRUE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
)

# Headers go in a package-specific directory, so they don't end up directly in a merged include directory
install(DIRECTORY "${${PROJECT_NAME}_ARCHIVE_DIR}/include/" DESTINATION include/${PROJECT_NAME})
# Preserve the archive's SONAME symlinks and install all runtime libraries, including the
# builder resources that are needed to create inference engines. The static libraries are skipped.
install(DIRECTORY "${${PROJECT_NAME}_ARCHIVE_DIR}/lib/" DESTINATION lib
  USE_SOURCE_PERMISSIONS
  FILES_MATCHING PATTERN "*.so*"
  PATTERN "stubs" EXCLUDE)

if(BUILD_TESTING)
  find_package(ament_cmake_lint_cmake REQUIRED)
  find_package(ament_cmake_xmllint REQUIRED)
  ament_lint_cmake(MAX_LINE_LENGTH 120)
  ament_xmllint(MAX_LINE_LENGTH 120)
endif()

ament_package(CONFIG_EXTRAS "cmake/${PROJECT_NAME}-extras.cmake.in")
