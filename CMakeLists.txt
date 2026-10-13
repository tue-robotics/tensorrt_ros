cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
project(tensorrt_ros)

find_package(ament_cmake REQUIRED)

set(TENSOR_RT_VERSION "10.16.1")
set(TENSOR_RT_BUILD "11")
set(TENSOR_RT_VERSION_FULL "${TENSOR_RT_VERSION}.${TENSOR_RT_BUILD}")
set(CUDA_MAX_VERSION "12.9")

set(TENSORRT_URL_BASE
  "https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/${TENSOR_RT_VERSION}/tars")
set(TENSORRT_FILENAME "TensorRT-${TENSOR_RT_VERSION_FULL}.Linux.x86_64-gnu.cuda-${CUDA_MAX_VERSION}.tar.gz")
set(TENSORRT_URL "${TENSORRT_URL_BASE}/${TENSORRT_FILENAME}" CACHE STRING "TensorRT binary archive URL or local path")

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux" OR NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
  message(FATAL_ERROR "The TensorRT binary archive requires Linux x86_64")
endif()

include(CheckLanguage)
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
  enable_language(CUDA)
  set(tensorrt_ros_CUDA_ENABLED TRUE)
else()
  set(tensorrt_ros_CUDA_ENABLED FALSE)
endif()

set(EP_NAME "EP_${PROJECT_NAME}")
set(TENSORRT_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/${EP_NAME}-prefix/src/${EP_NAME}")

include(ExternalProject)
externalproject_add(${EP_NAME}
  URL "${TENSORRT_URL}"
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  DOWNLOAD_NO_PROGRESS TRUE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  UPDATE_COMMAND ""
  INSTALL_COMMAND ""
)

install(DIRECTORY "${TENSORRT_SOURCE_DIR}/include/" DESTINATION include)
# Preserve the archive's SONAME symlinks and all runtime libraries, including
# builder resources needed when creating inference engines.
install(DIRECTORY "${TENSORRT_SOURCE_DIR}/lib/" DESTINATION lib
  FILES_MATCHING PATTERN "*.so*")

if(APPLE)
  set(ENV_VAR_NAME DYLD_LIBRARY_PATH)
else()
  set(ENV_VAR_NAME LD_LIBRARY_PATH)
endif()
ament_environment_hooks(
  "${CMAKE_CURRENT_SOURCE_DIR}/env-hooks/99.tensorrt_ros_library_path.sh.in"
  "${CMAKE_CURRENT_SOURCE_DIR}/env-hooks/99.tensorrt_ros_library_path.dsv.in"
)

if(BUILD_TESTING)
  find_package(ament_cmake_lint_cmake REQUIRED)
  find_package(ament_cmake_xmllint REQUIRED)
  ament_lint_cmake(MAX_LINE_LENGTH 120)
  ament_xmllint(MAX_LINE_LENGTH 120)
endif()

ament_package(CONFIG_EXTRAS "cmake/tensorrt_ros-extras.cmake.in")
