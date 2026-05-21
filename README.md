# tensorrt_ros

This `catkin` project acts as a wrapper for the NVIDIA TensorRT library. It downloads the pre-compiled TensorRT binary archive and automatically integrates its headers, libraries, and CMake configuration into the corresponding directories of your ROS workspace target folder (`devel` or `install`).

This allows other ROS packages in your workspace to easily depend on TensorRT C++ APIs.

## Usage in `package.xml`

To use TensorRT in your ROS package, add it as a dependency in your `package.xml`:

```xml
  <depend>tensorrt_ros</depend>
```

## Usage in `CMakeLists.txt`

You can link against TensorRT by including it in your `find_package` call:

```cmake
find_package(catkin REQUIRED COMPONENTS
  tensorrt_ros
)

catkin_package(
  ...
  CATKIN_DEPENDS tensorrt_ros # If your package exports TensorRT dependencies
)

include_directories(
  ${catkin_INCLUDE_DIRS}
)

# Example for an executable (e.g. a ROS Node)
add_executable(my_tensorrt_node src/my_node.cpp)
target_link_libraries(my_tensorrt_node ${catkin_LIBRARIES})

# Example for a library
add_library(my_tensorrt_lib src/my_lib.cpp)
target_link_libraries(my_tensorrt_lib ${catkin_LIBRARIES})
```

## Note on CUDA

The CMake configuration automatically checks if a CUDA compiler (`nvcc`) is available on your system. If CMake fails to find CUDA and logs an issue, ensure that your CUDA toolkit is properly installed and that `nvcc` is in your system's `$PATH`, or set it manually:

```sh
export CUDACXX=/usr/local/cuda/bin/nvcc
```
