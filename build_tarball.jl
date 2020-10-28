# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "OpenCV"
version = v"0.2.4"

# Collection of sources required to complete build
sources = [
    GitSource(
      "https://github.com/opencv/opencv.git",
      "d5fd2f0155ffad366f9ac912dfd6d189a7a6a98e",
    ),
]
# Bash recipe for building across all platforms
script = raw"""
# Override compiler ID to silence the horrible "No features found" cmake error
if [[ $target == *"apple-darwin"* ]]; then
  macos_extra_flags="-DCMAKE_CXX_COMPILER_ID=AppleClang -DCMAKE_CXX_COMPILER_VERSION=10.0.0 -DCMAKE_CXX_STANDARD_COMPUTED_DEFAULT=11"
fi

if [[ $target == "x86_64-linux-gnu"* ]]; then
  gui_flags="-DWITH_QT=ON"
fi

Julia_PREFIX=$prefix

mkdir build
cd build
cmake -DCMAKE_FIND_ROOT_PATH=$prefix \
      -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
      $macos_extra_flags -DCMAKE_BUILD_TYPE=Release \
      $gui_flags \
      ../opencv/
VERBOSE=ON cmake --build . --config Release --target install -- -j${nproc}
cd ..
install_license opencv/LICENSE
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    #FreeBSD(:x86_64; compiler_abi=CompilerABI(cxxstring_abi=:cxx11)), <- fails
    #Linux(:armv7l; libc=:glibc, compiler_abi=CompilerABI(cxxstring_abi=:cxx11)),
    #Linux(:aarch64; libc=:glibc, compiler_abi=CompilerABI(cxxstring_abi=:cxx11)),
    Linux(:x86_64; libc=:glibc, compiler_abi=CompilerABI(cxxstring_abi=:cxx11)),
    #Linux(:i686; libc=:glibc, compiler_abi=CompilerABI(cxxstring_abi=:cxx11)),
    #MacOS(:x86_64; compiler_abi=CompilerABI(cxxstring_abi=:cxx11)),
    #Windows(:x86_64; compiler_abi=CompilerABI(cxxstring_abi=:cxx11)),
    #Windows(:i686; compiler_abi=CompilerABI(cxxstring_abi=:cxx11)),
]
                                
# The products that we will ensure are always built
products = [
    LibraryProduct(["libopencv_calib3d", "libopencv_calib3d450"], :libopencv_calib3d),
    LibraryProduct(["libopencv_core", "libopencv_core450"], :libopencv_core),
    LibraryProduct(["libopencv_dnn", "libopencv_dnn450"], :libopencv_dnn),
    LibraryProduct(["libopencv_features2d", "libopencv_features2d450"], :libopencv_features2d),
    LibraryProduct(["libopencv_flann", "libopencv_flann450"], :libopencv_flann),
    LibraryProduct(["libopencv_gapi", "libopencv_gapi450"], :libopencv_gapi),
    LibraryProduct(["libopencv_highgui", "libopencv_highgui450"], :libopencv_highgui),
    LibraryProduct(["libopencv_imgcodecs", "libopencv_imgcodecs450"], :libopencv_imgcodecs),
    LibraryProduct(["libopencv_imgproc", "libopencv_imgproc450"], :libopencv_imgproc),
    LibraryProduct(["libopencv_ml", "libopencv_ml450"], :libopencv_ml),
    LibraryProduct(["libopencv_objdetect", "libopencv_objdetect450"], :libopencv_objdetect),
    LibraryProduct(["libopencv_photo", "libopencv_photo450"], :libopencv_photo),
    LibraryProduct(["libopencv_stitching", "libopencv_stitching450"], :libopencv_stitching),
    LibraryProduct(["libopencv_video", "libopencv_video450"], :libopencv_video),
    LibraryProduct(["libopencv_videoio", "libopencv_videoio450"], :libopencv_videoio),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("Qt_jll"),
    BuildDependency("GTK3_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; preferred_gcc_version = v"7")
