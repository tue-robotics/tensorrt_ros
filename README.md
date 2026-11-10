# tensorrt_ros

This CMake project downloads the binary NVIDIA TensorRT archive (Linux x86_64, CUDA 12.x) and installs its headers and libraries into the ROS 2 install prefix.
The package version is the TensorRT version that gets downloaded.

The package can be used in a ROS 2 workspace by adding:
```XML
  <depend>tensorrt_ros</depend>
```
to your `package.xml`. Headers are installed to `include/tensorrt_ros` and libraries to `lib` of the workspace install folder.

Usage in a CMake project:
```CMake
find_package(tensorrt_ros REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC tensorrt_ros::tensorrt_ros)
```
`tensorrt_ros::tensorrt_ros` links `nvinfer`, `nvinfer_plugin` and `nvonnxparser`. To link a single library, use `tensorrt_ros::nvinfer`, `tensorrt_ros::nvinfer_plugin` or `tensorrt_ros::nvonnxparser`.
`tensorrt_ros_INCLUDE_DIRS` and `tensorrt_ros_LIBRARIES` are also available.
`tensorrt_ros_CUDA_ENABLED` tells whether a CUDA compiler was found when this package was built.

If you get the error `No CMAKE_CUDA_COMPILER could be found.`, then the CUDA compiler `nvcc` cannot be found in the default search paths (`$PATH`). In this case, you have to set the path to `nvcc` manually:
```sh
export CUDACXX=/usr/local/cuda/bin/nvcc
```
