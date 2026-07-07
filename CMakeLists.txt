cmake_minimum_required(VERSION 3.24 FATAL_ERROR)
project(tensorrt_ros)

cmake_policy(SET CMP0097 NEW)
cmake_policy(SET CMP0148 OLD)

find_package(catkin REQUIRED)

catkin_package_xml()
# split version in parts and pass to extra file
string(REPLACE "." ";" ${PROJECT_NAME}_VERSION_LIST "${${PROJECT_NAME}_VERSION}")
list(LENGTH ${PROJECT_NAME}_VERSION_LIST _count)
if(NOT _count EQUAL 3)
  message(FATAL_ERROR "${PROJECT_NAME} version '${${PROJECT_NAME}_VERSION}' does not match 'MAJOR.MINOR.PATCH' pattern")
endif()
list(GET ${PROJECT_NAME}_VERSION_LIST 0 ${PROJECT_NAME}_VERSION_MAJOR)
list(GET ${PROJECT_NAME}_VERSION_LIST 1 ${PROJECT_NAME}_VERSION_MINOR)
list(GET ${PROJECT_NAME}_VERSION_LIST 2 ${PROJECT_NAME}_VERSION_PATCH)

if(NOT ${CMAKE_VERBOSE_MAKEFILE})
  set(should_log ON)
else()
  set(should_log OFF)
endif()

set(PROJECT_VERSION "10.16.1")
set(TENSOR_RT_BUILD "11")

set(TENSOR_RT_VERSION "${PROJECT_VERSION}")
set(TENSOR_RT_VERSION_FULL "${PROJECT_VERSION}.${TENSOR_RT_BUILD}")

set(CUDA_MAX_VERSION "12.9")

set(TENSORRT_URL_BASE "https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/${TENSOR_RT_VERSION}/tars")

set(EP_NAME "EP_${PROJECT_NAME}")
set(TENSORRT_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/${EP_NAME}-prefix/src/${EP_NAME}")
set(TENSORRT_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/${EP_NAME}_install")
set(TENSORRT_INCLUDE_DIR
    "${TENSORRT_INSTALL_DIR}/include"
    CACHE PATH "tensorrt include directory." FORCE)
set(TENSORRT_LIB_DIR
    "${TENSORRT_INSTALL_DIR}/lib"
    CACHE PATH "tensorrt lib directory." FORCE)

set(_install_commands
  COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different ${TENSORRT_SOURCE_DIR}/include ${CATKIN_DEVEL_PREFIX}/${CATKIN_GLOBAL_INCLUDE_DESTINATION}

  # libnvinfer
  COMMAND ${CMAKE_COMMAND} -E copy_if_different "${TENSORRT_SOURCE_DIR}/lib/libnvinfer.so.${TENSOR_RT_VERSION}" ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer.so.${TENSOR_RT_VERSION}
  COMMAND ${CMAKE_COMMAND} -E create_symlink libnvinfer.so.${TENSOR_RT_VERSION} ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer.so.10
  COMMAND ${CMAKE_COMMAND} -E create_symlink libnvinfer.so.10 ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer.so

  # libnvinfer_plugin
  COMMAND ${CMAKE_COMMAND} -E copy_if_different "${TENSORRT_SOURCE_DIR}/lib/libnvinfer_plugin.so.${TENSOR_RT_VERSION}" ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer_plugin.so.${TENSOR_RT_VERSION}
  COMMAND ${CMAKE_COMMAND} -E create_symlink libnvinfer_plugin.so.${TENSOR_RT_VERSION} ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer_plugin.so.10
  COMMAND ${CMAKE_COMMAND} -E create_symlink libnvinfer_plugin.so.10 ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer_plugin.so

  # libnvonnxparser
  COMMAND ${CMAKE_COMMAND} -E copy_if_different "${TENSORRT_SOURCE_DIR}/lib/libnvonnxparser.so.${TENSOR_RT_VERSION}" ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvonnxparser.so.${TENSOR_RT_VERSION}
  COMMAND ${CMAKE_COMMAND} -E create_symlink libnvonnxparser.so.${TENSOR_RT_VERSION} ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvonnxparser.so.10
  COMMAND ${CMAKE_COMMAND} -E create_symlink libnvonnxparser.so.10 ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvonnxparser.so
)

set(_build_byproducts
  "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer.so.${TENSOR_RT_VERSION}"
  "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer.so"
  "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer_plugin.so.${TENSOR_RT_VERSION}"
  "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvinfer_plugin.so"
  "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvonnxparser.so.${TENSOR_RT_VERSION}"
  "${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/libnvonnxparser.so"
)

set(_install_files
  "${TENSORRT_LIB_DIR}/libnvinfer.so.${TENSOR_RT_VERSION}"
  "${TENSORRT_LIB_DIR}/libnvinfer_plugin.so.${TENSOR_RT_VERSION}"
  "${TENSORRT_LIB_DIR}/libnvonnxparser.so.${TENSOR_RT_VERSION}"
)

include(CheckLanguage)
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
  enable_language(CUDA)
  message(STATUS "Compiling with CUDA")
  set(TENSORRT_FILENAME "TensorRT-${TENSOR_RT_VERSION_FULL}.Linux.x86_64-gnu.cuda-${CUDA_MAX_VERSION}.tar.gz")
  list(APPEND _install_commands
    COMMAND bash -c "cp -a ${TENSORRT_SOURCE_DIR}/lib/libnvinfer_builder_resource*.so* ${CATKIN_DEVEL_PREFIX}/${CATKIN_PACKAGE_LIB_DESTINATION}/ || true"
  )
else()
  message(STATUS "Compiling without CUDA")
  set(TENSORRT_FILENAME "TensorRT-${TENSOR_RT_VERSION_FULL}.Linux.x86_64-gnu.cuda-${CUDA_MAX_VERSION}.tar.gz")
endif()

include(ExternalProject)
externalproject_add(${EP_NAME}
  URL "${TENSORRT_URL_BASE}/${TENSORRT_FILENAME}"
  DOWNLOAD_NO_PROGRESS NOT ${should_log}
  LOG_CONFIGURE ${should_log}
  LOG_BUILD ${should_log}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  UPDATE_COMMAND ""
  INSTALL_COMMAND ${_install_commands}
  BUILD_BYPRODUCTS ${_build_byproducts}
)

install(
  DIRECTORY ${TENSORRT_SOURCE_DIR}/include/
  DESTINATION ${CATKIN_GLOBAL_INCLUDE_DESTINATION}
)
install(
  DIRECTORY ${TENSORRT_SOURCE_DIR}/lib/
  DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  FILES_MATCHING PATTERN "*.so*"
)

if(CMAKE_CUDA_COMPILER)
    set(${PROJECT_NAME}_CUDA_ENABLED TRUE)
else()
    set(${PROJECT_NAME}_CUDA_ENABLED FALSE)
endif()

catkin_package(
  CFG_EXTRAS ${PROJECT_NAME}-extras.cmake
  EXPORTED_TARGETS ${EP_NAME}
)

if(CATKIN_ENABLE_TESTING)
  find_package(catkin_lint_cmake REQUIRED)
  catkin_add_catkin_lint_test("-W2 --ignore GLOBAL_VAR_COLLISION --ignore MISSING_DIRECTORY --ignore MISSING_FILE --ignore UNDEFINED_TARGET")
endif()
