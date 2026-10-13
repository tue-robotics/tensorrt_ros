# tensorrt_ros

This ROS 2 `ament_cmake` package downloads the NVIDIA TensorRT 10.16.1 binary
archive for Linux x86_64 and installs its headers and shared libraries into the
package's install prefix. Source your workspace setup to add its libraries to
the runtime library search path.

## Build

```sh
colcon build --packages-select tensorrt_ros
source install/setup.bash
colcon test --packages-select tensorrt_ros
colcon test-result --verbose
```

The build requires network access to NVIDIA's archive. To use a previously
downloaded archive, pass `--cmake-args -DTENSORRT_URL=/path/to/TensorRT.tar.gz`.

## Usage in package.xml

```xml
<depend>tensorrt_ros</depend>
```

## Usage in CMakeLists.txt

```cmake
find_package(ament_cmake REQUIRED)
find_package(tensorrt_ros REQUIRED)

add_executable(my_tensorrt_node src/my_node.cpp)
target_link_libraries(my_tensorrt_node PRIVATE tensorrt_ros::tensorrt_ros)

add_library(my_tensorrt_lib SHARED src/my_lib.cpp)
target_link_libraries(my_tensorrt_lib PUBLIC tensorrt_ros::tensorrt_ros)

# If your exported library exposes TensorRT to downstream consumers:
ament_export_dependencies(tensorrt_ros)
# Install and export your own library targets before calling ament_package().
ament_package()
```

For individual libraries, link `tensorrt_ros::nvinfer`,
`tensorrt_ros::nvinfer_plugin`, or `tensorrt_ros::nvonnxparser`.
`tensorrt_ros_INCLUDE_DIRS`, `tensorrt_ros_LIBRARIES`, and
`tensorrt_ros_CUDA_ENABLED` remain available for consumers using CMake variables.

## CUDA

The binary archive targets CUDA 12.9. CUDA runtime dependencies must be available
on the target system. The CMake configuration checks for a CUDA compiler (`nvcc`)
and reports its availability through `tensorrt_ros_CUDA_ENABLED`. To select a
CUDA compiler explicitly:

```sh
export CUDACXX=/usr/local/cuda/bin/nvcc
```
