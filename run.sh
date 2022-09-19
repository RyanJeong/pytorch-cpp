# Requirements:
#   1. Ubuntu 18.04 LTS
#   2. linaro compiler
#     (1) linaro-aarch64-2018.08-gcc8.2
#     (2) linaro-aarch64-2020.09-gcc10.2-linux5.4
#   3. python 3.7.x
#     sudo apt update
#     sudo apt install software-properties-common
#     sudo add-apt-repository ppa:deadsnakes/ppa # when prompted, press ENTER to continue
#     sudo apt install python3.7
#     python3.7 --version
#     which python3.7

# 0. Default parameters
NUM_CORE=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+1}')
export PATH=$PATH:/usr/local/linaro-aarch64-2020.09-gcc10.2-linux5.4/bin
export LD_LIBRARY_PATH=/usr/local/linaro-aarch64-2020.09-gcc10.2-linux5.4/lib
WORKING_DIR=$(pwd)
LIBTORCH_PREFIX=/usr/local/libtorch/arm64
TORCHVISION=PREFIX/usr/local/torchvision/arm64
LIBTORCH_DEPENDENCIES=/usr/local/pytorch-aarch64
PYTORCH_TOOLCHAIN=toolchain.cmake

# 1. Copy TryRunResults.cmake
cd $WORKING_DIR/

sudo mkdir -p $LIBTORCH_PREFIX/
sudo chmod 777 -R $LIBTORCH_PREFIX/
sudo mkdir -p $TORCHVISION/
sudo chmod 777 -R $TORCHVISION/
sudo mkdir -p $LIBTORCH_DEPENDENCIES/
sudo chmod 777 -R $LIBTORCH_DEPENDENCIES/
cp $WORKING_DIR/TryRunResults.cmake $LIBTORCH_DEPENDENCIES/

# 2. Compile boost library
cd $WORKING_DIR/

PYTORCH_BOOST_VERSION_MAJOR=1
PYTORCH_BOOST_VERSION_MINOR=68
PYTORCH_BOOST_VERSION_PATCH=0
PYTORCH_BOOST="boost_\
$PYTORCH_BOOST_VERSION_MAJOR"_"\
$PYTORCH_BOOST_VERSION_MINOR"_"\
$PYTORCH_BOOST_VERSION_PATCH"
PYTORCH_BOOST_URL="https://boostorg.jfrog.io/artifactory/main/release/\
$PYTORCH_BOOST_VERSION_MAJOR"."\
$PYTORCH_BOOST_VERSION_MINOR"."\
$PYTORCH_BOOST_VERSION_PATCH/source/$PYTORCH_BOOST.tar.gz"

wget $PYTORCH_BOOST_URL
tar -xvf $WORKING_DIR/$PYTORCH_BOOST.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_BOOST/
./bootstrap.sh
cp $WORKING_DIR/project-config.jam ./
./bjam install \
  toolset=gcc-arm64 \
  variant=release \
  link=shared \
  threading=multi \
  runtime-link=shared \
  --prefix=$LIBTORCH_DEPENDENCIES \
  --with-thread \
  --with-system \
  --with-filesystem \
  -j$NUM_CORE

# 3. Compile gflags library
cd $WORKING_DIR/

PYTORCH_GFLAGS_VERSION_MAJOR=2
PYTORCH_GFLAGS_VERSION_MINOR=2
PYTORCH_GFLAGS_VERSION_PATCH=2
PYTORCH_GFLAGS="gflags-\
$PYTORCH_GFLAGS_VERSION_MAJOR"."\
$PYTORCH_GFLAGS_VERSION_MINOR"."\
$PYTORCH_GFLAGS_VERSION_PATCH"
PYTORCH_GFLAGS_URL="https://github.com/gflags/gflags/archive/refs/tags/v\
$PYTORCH_GFLAGS_VERSION_MAJOR"."\
$PYTORCH_GFLAGS_VERSION_MINOR"."\
$PYTORCH_GFLAGS_VERSION_PATCH".tar.gz

wget $PYTORCH_GFLAGS_URL
tar -xvf $WORKING_DIR/v$PYTORCH_GFLAGS_VERSION_MAJOR.$PYTORCH_GFLAGS_VERSION_MINOR.$PYTORCH_GFLAGS_VERSION_PATCH.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_GFLAGS/
mkdir aarch64_build
cd aarch64_build/
cmake .. -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_DEPENDENCIES \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE

# 4. Compile glog library
cd $WORKING_DIR/

PYTORCH_GLOG_VERSION_MAJOR=0
PYTORCH_GLOG_VERSION_MINOR=4
PYTORCH_GLOG_VERSION_PATCH=0
PYTORCH_GLOG="glog-\
$PYTORCH_GLOG_VERSION_MAJOR"."\
$PYTORCH_GLOG_VERSION_MINOR"."\
$PYTORCH_GLOG_VERSION_PATCH"
PYTORCH_GLOG_URL="https://github.com/google/glog/archive/refs/tags/v\
$PYTORCH_GLOG_VERSION_MAJOR"."\
$PYTORCH_GLOG_VERSION_MINOR"."\
$PYTORCH_GLOG_VERSION_PATCH".tar.gz

wget $PYTORCH_GLOG_URL
tar -xvf $WORKING_DIR/v$PYTORCH_GLOG_VERSION_MAJOR.$PYTORCH_GLOG_VERSION_MINOR.$PYTORCH_GLOG_VERSION_PATCH.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_GLOG/
mkdir aarch64_build
cd aarch64_build/
cmake .. -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_DEPENDENCIES \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE

# 5. Compile leveldb library
cd $WORKING_DIR/

PYTORCH_LEVELDB_VERSION_MAJOR=1
PYTORCH_LEVELDB_VERSION_MINOR=23
PYTORCH_LEVELDB="leveldb-\
$PYTORCH_LEVELDB_VERSION_MAJOR"."\
$PYTORCH_LEVELDB_VERSION_MINOR"
PYTORCH_LEVELDB_URL="https://github.com/google/leveldb/archive/refs/tags/\
$PYTORCH_LEVELDB_VERSION_MAJOR"."\
$PYTORCH_LEVELDB_VERSION_MINOR".tar.gz

wget $PYTORCH_LEVELDB_URL
tar -xvf $WORKING_DIR/$PYTORCH_LEVELDB_VERSION_MAJOR.$PYTORCH_LEVELDB_VERSION_MINOR.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_LEVELDB/
mkdir aarch64_build
cd aarch64_build/
cmake .. -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_DEPENDENCIES \
  -DCMAKE_BUILD_TYPE=Release \
  -DLEVELDB_BUILD_TESTS=OFF \
  -DLEVELDB_BUILD_BENCHMARKS=OFF \
  -DBUILD_SHARED_LIBS=ON
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE

# 6. Compile openldap library
cd $WORKING_DIR/

PYTORCH_OPENLDAP_VERSION_MAJOR=0
PYTORCH_OPENLDAP_VERSION_MINOR=9
PYTORCH_OPENLDAP_VERSION_PATCH=24
PYTORCH_OPENLDAP="openldap-LMDB_\
$PYTORCH_OPENLDAP_VERSION_MAJOR"."\
$PYTORCH_OPENLDAP_VERSION_MINOR"."\
$PYTORCH_OPENLDAP_VERSION_PATCH"
PYTORCH_OPENLDAP_URL="https://git.openldap.org/openldap/openldap/-/archive/LMDB_\
$PYTORCH_OPENLDAP_VERSION_MAJOR"."\
$PYTORCH_OPENLDAP_VERSION_MINOR"."\
$PYTORCH_OPENLDAP_VERSION_PATCH/$PYTORCH_OPENLDAP.tar.gz"

wget $PYTORCH_OPENLDAP_URL
tar -xvf $WORKING_DIR/$PYTORCH_OPENLDAP.tar.gz
rm *.tar.gz
cp $WORKING_DIR/Makefile $WORKING_DIR/$PYTORCH_OPENLDAP/libraries/liblmdb
cd $PYTORCH_OPENLDAP/libraries/liblmdb
make -j$NUM_CORE install

# 7. Compile OpenBLAS library
cd $WORKING_DIR/

PYTORCH_OPENBLAS_VERSION_MAJOR=0
PYTORCH_OPENBLAS_VERSION_MINOR=3
PYTORCH_OPENBLAS_VERSION_PATCH=7
PYTORCH_OPENBLAS="OpenBLAS-\
$PYTORCH_OPENBLAS_VERSION_MAJOR"."\
$PYTORCH_OPENBLAS_VERSION_MINOR"."\
$PYTORCH_OPENBLAS_VERSION_PATCH"
PYTORCH_OPENBLAS_URL="https://github.com/xianyi/OpenBLAS/archive/refs/tags/v\
$PYTORCH_OPENBLAS_VERSION_MAJOR"."\
$PYTORCH_OPENBLAS_VERSION_MINOR"."\
$PYTORCH_OPENBLAS_VERSION_PATCH".tar.gz

wget $PYTORCH_OPENBLAS_URL
tar -xvf $WORKING_DIR/v$PYTORCH_OPENBLAS_VERSION_MAJOR.$PYTORCH_OPENBLAS_VERSION_MINOR.$PYTORCH_OPENBLAS_VERSION_PATCH.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_OPENBLAS/
mkdir aarch64_build
cd aarch64_build/
cmake .. -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_DEPENDENCIES \
  -DCMAKE_BUILD_TYPE=Release \
  -DNOFORTRAN=1 \
  -DBUILD_SHARED_LIBS=ON
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE

export OpenBLAS_HOME=$LIBTORCH_DEPENDENCIES/include/openblas
export OpenBLAS=$LIBTORCH_DEPENDENCIES

# 8. Compile protobuf library
cd $WORKING_DIR/

PYTORCH_PROTOBUF_VERSION_MAJOR=3
PYTORCH_PROTOBUF_VERSION_MINOR=10
PYTORCH_PROTOBUF_VERSION_PATCH=1
PYTORCH_PROTOBUF="protobuf-\
$PYTORCH_PROTOBUF_VERSION_MAJOR"."\
$PYTORCH_PROTOBUF_VERSION_MINOR"."\
$PYTORCH_PROTOBUF_VERSION_PATCH"
PYTORCH_PROTOBUF_URL="https://github.com/protocolbuffers/protobuf/archive/refs/tags/v\
$PYTORCH_PROTOBUF_VERSION_MAJOR"."\
$PYTORCH_PROTOBUF_VERSION_MINOR"."\
$PYTORCH_PROTOBUF_VERSION_PATCH".tar.gz

wget $PYTORCH_PROTOBUF_URL
tar -xvf $WORKING_DIR/v$PYTORCH_PROTOBUF_VERSION_MAJOR.$PYTORCH_PROTOBUF_VERSION_MINOR.$PYTORCH_PROTOBUF_VERSION_PATCH.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_PROTOBUF/
mkdir aarch64_build
cd aarch64_build/
cmake ../cmake -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_DEPENDENCIES \
  -DCMAKE_BUILD_TYPE=Release \
  -Dprotobuf_BUILD_TESTS=OFF
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE
export PATH=$PATH:$LIBTORCH_DEPENDENCIES/bin

# 9. Compile opencv library
cd $WORKING_DIR/

PYTORCH_OPENCV_VERSION_MAJOR=3
PYTORCH_OPENCV_VERSION_MINOR=4
PYTORCH_OPENCV_VERSION_PATCH=8
PYTORCH_OPENCV="opencv-\
$PYTORCH_OPENCV_VERSION_MAJOR"."\
$PYTORCH_OPENCV_VERSION_MINOR"."\
$PYTORCH_OPENCV_VERSION_PATCH"
PYTORCH_OPENCV_URL="https://github.com/opencv/opencv/archive/refs/tags/\
$PYTORCH_OPENCV_VERSION_MAJOR"."\
$PYTORCH_OPENCV_VERSION_MINOR"."\
$PYTORCH_OPENCV_VERSION_PATCH".tar.gz

wget $PYTORCH_OPENCV_URL
tar -xvf $WORKING_DIR/$PYTORCH_OPENCV_VERSION_MAJOR.$PYTORCH_OPENCV_VERSION_MINOR.$PYTORCH_OPENCV_VERSION_PATCH.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_OPENCV/
mkdir aarch64_build
cd aarch64_build/

cmake .. -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_DEPENDENCIES \
  -DCMAKE_BUILD_TYPE=Release \
  -DWITH_CUDA=OFF \
  -DZLIB_INCLUDE_DIR=../3rdparty/zlib \
  -DBUILD_PERF_TESTS=OFF \
  -DBUILD_TESTS=OFF \
  -DBUILD_ZLIB=ON \
  -DBUILD_opencv_core=ON \
  -DBUILD_opencv_highgui=ON \
  -DBUILD_opencv_imgcodecs=ON \
  -DBUILD_opencv_imgproc=ON \
  -DBUILD_opencv_video=ON \
  -DBUILD_opencv_videoio=ON \
  -DBUILD_opencv_apps=OFF \
  -DBUILD_opencv_calib3d=OFF \
  -DBUILD_opencv_dnn=OFF \
  -DBUILD_opencv_features2d=OFF \
  -DBUILD_opencv_flann=OFF \
  -DBUILD_opencv_java_bindings_generator=OFF \
  -DBUILD_opencv_js=OFF \
  -DBUILD_opencv_ml=OFF \
  -DBUILD_opencv_objdetect=OFF \
  -DBUILD_opencv_photo=OFF \
  -DBUILD_opencv_python_bindings_generator=OFF \
  -DBUILD_opencv_python_tests=OFF \
  -DBUILD_opencv_shape=OFF \
  -DBUILD_opencv_stitching=OFF \
  -DBUILD_opencv_superres=OFF \
  -DBUILD_opencv_videostab=OFF \
  -DBUILD_opencv_world=OFF

# ###### NOTICE ######
# * if gcc >= 10.0, need to replace ipcp-unit-growth with ipa-cp-unit-growth
# * else, you don't need to do two steps as below
sed -i 's/ipcp-unit-growth/ipa-cp-unit-growth/g' $WORKING_DIR/$PYTORCH_OPENCV/aarch64_build/3rdparty/carotene/hal/carotene/CMakeFiles/carotene_objs.dir/build.make
sed -i 's/ipcp-unit-growth/ipa-cp-unit-growth/g' $WORKING_DIR/$PYTORCH_OPENCV/aarch64_build/3rdparty/carotene/hal/carotene/CMakeFiles/carotene_objs.dir/flags.make

cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE

# 10. Compile snappy library
cd $WORKING_DIR/

PYTORCH_SNAPPY_VERSION_MAJOR=1
PYTORCH_SNAPPY_VERSION_MINOR=1
PYTORCH_SNAPPY_VERSION_PATCH=7
PYTORCH_SNAPPY="snappy-\
$PYTORCH_SNAPPY_VERSION_MAJOR"."\
$PYTORCH_SNAPPY_VERSION_MINOR"."\
$PYTORCH_SNAPPY_VERSION_PATCH"
PYTORCH_SNAPPY_URL="https://github.com/google/snappy/archive/refs/tags/\
$PYTORCH_SNAPPY_VERSION_MAJOR"."\
$PYTORCH_SNAPPY_VERSION_MINOR"."\
$PYTORCH_SNAPPY_VERSION_PATCH".tar.gz

wget $PYTORCH_SNAPPY_URL
tar -xvf $WORKING_DIR/$PYTORCH_SNAPPY_VERSION_MAJOR.$PYTORCH_SNAPPY_VERSION_MINOR.$PYTORCH_SNAPPY_VERSION_PATCH.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_SNAPPY/
mkdir aarch64_build
cd aarch64_build/
cmake .. -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_DEPENDENCIES \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DSNAPPY_BUILD_TESTS=OFF
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE

# 11. Compile rocksdb library
cd $WORKING_DIR/

PYTORCH_ROCKSDB_VERSION_MAJOR=6
PYTORCH_ROCKSDB_VERSION_MINOR=4
PYTORCH_ROCKSDB_VERSION_PATCH=6
PYTORCH_ROCKSDB="rocksdb-\
$PYTORCH_ROCKSDB_VERSION_MAJOR"."\
$PYTORCH_ROCKSDB_VERSION_MINOR"."\
$PYTORCH_ROCKSDB_VERSION_PATCH"
PYTORCH_ROCKSDB_URL="https://github.com/facebook/rocksdb/archive/refs/tags/v\
$PYTORCH_ROCKSDB_VERSION_MAJOR"."\
$PYTORCH_ROCKSDB_VERSION_MINOR"."\
$PYTORCH_ROCKSDB_VERSION_PATCH".tar.gz

wget $PYTORCH_ROCKSDB_URL
tar -xvf $WORKING_DIR/v$PYTORCH_ROCKSDB_VERSION_MAJOR.$PYTORCH_ROCKSDB_VERSION_MINOR.$PYTORCH_ROCKSDB_VERSION_PATCH.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_ROCKSDB/
mkdir aarch64_build
cd aarch64_build/
cmake .. -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_DEPENDENCIES \
  -DCMAKE_BUILD_TYPE=Release \
  -DWITH_TESTS=OFF \
  -DWITH_TOOLS=OFF \
  -DWITH_GFLAGS=OFF \
  -DPORTABLE=ON
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE

# 12. Compile libzmq library
cd $WORKING_DIR/

PYTORCH_LIBZMQ_VERSION_MAJOR=4
PYTORCH_LIBZMQ_VERSION_MINOR=3
PYTORCH_LIBZMQ_VERSION_PATCH=4
PYTORCH_LIBZMQ="libzmq-\
$PYTORCH_LIBZMQ_VERSION_MAJOR"."\
$PYTORCH_LIBZMQ_VERSION_MINOR"."\
$PYTORCH_LIBZMQ_VERSION_PATCH"
PYTORCH_LIBZMQ_URL="https://github.com/zeromq/libzmq/archive/refs/tags/v\
$PYTORCH_LIBZMQ_VERSION_MAJOR"."\
$PYTORCH_LIBZMQ_VERSION_MINOR"."\
$PYTORCH_LIBZMQ_VERSION_PATCH".tar.gz

wget $PYTORCH_LIBZMQ_URL
tar -xvf $WORKING_DIR/v$PYTORCH_LIBZMQ_VERSION_MAJOR.$PYTORCH_LIBZMQ_VERSION_MINOR.$PYTORCH_LIBZMQ_VERSION_PATCH.tar.gz
rm *.tar.gz
cd $WORKING_DIR/$PYTORCH_LIBZMQ/
mkdir aarch64_build
cd aarch64_build/
cmake .. -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_DEPENDENCIES \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_STATIC=OFF \
  -DBUILD_TESTS=OFF \
  -DWITH_DOCS=OFF \
  -DWITH_PERF_TOOL=OFF
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE

# 13. Compile pytorch library
cd $WORKING_DIR/

git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
export LIBTORCH_ROOT=$(pwd)
git checkout v1.7.1
git submodule sync
git submodule update --init --recursive

cp $WORKING_DIR/CMakeLists.txt $LIBTORCH_ROOT
cp $WORKING_DIR/TorchConfig.cmake.in $LIBTORCH_ROOT/cmake
$LIBTORCH_ROOT/scripts/build_host_protoc.sh

cd $LIBTORCH_ROOT/third_party/sleef

# ###### NOTICE ######
# * if gcc >= 10.0, need to change sleef version to e0a003e
# https://github.com/pytorch/pytorch/issues/45971
# git checkout e0a003e
git pull origin master
git reset --hard e0a003e

mkdir host_build
cd host_build/
cmake .. -G"Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=build \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTS=OFF
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE

cd $LIBTORCH_ROOT
mkdir aarch64_build
cd aarch64_build/
cmake $LIBTORCH_ROOT -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$LIBTORCH_PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCAFFE2_CUSTOM_PROTOC_EXECUTABLE=$LIBTORCH_ROOT/build_host_protoc/bin/protoc \
  -DCMAKE_PREFIX_PATH=$LIBTORCH_DEPENDENCIES \
  -DPYTHON_EXECUTABLE=$(which python3.7) \
  -C$LIBTORCH_DEPENDENCIES/TryRunResults.cmake \
  -DBUILDING_WITH_TORCH_LIBS=ON \
  -DBUILD_BINARY=ON \
  -DBUILD_CAFFE2_MOBILE=ON \
  -DBUILD_CAFFE2_OPS=ON \
  -DBUILD_CUSTOM_PROTOBUF=ON \
  -DBUILD_DFT=OFF \
  -DBUILD_DOCS=OFF \
  -DBUILD_GMOCK=ON \
  -DBUILD_GNUABI_LIBS=OFF \
  -DBUILD_LIBM=ON \
  -DBUILD_ONNX_PYTHON=OFF \
  -DBUILD_PYTHON=OFF \
  -DBUILD_QUAD=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TEST=ON \
  -DBUILD_TESTS=ON \
  -DUSE_ASAN=OFF \
  -DUSE_CUDA=OFF \
  -DUSE_DISTRIBUTED=OFF \
  -DUSE_FBGEMM=OFF \
  -DUSE_FFMPEG=ON \
  -DUSE_GFLAGS=ON \
  -DUSE_GLOG=ON \
  -DUSE_GLOO=OFF \
  -DUSE_LEVELDB=ON \
  -DUSE_LITE_PROTO=OFF \
  -DUSE_LMDB=ON \
  -DUSE_METAL=OFF \
  -DUSE_MKLDNN=OFF \
  -DUSE_MPI=OFF \
  -DUSE_NATIVE_ARCH=OFF \
  -DUSE_NNAPI=OFF \
  -DUSE_NNPACK=ON \
  -DUSE_NUMA=OFF \
  -DUSE_NUMPY=ON \
  -DUSE_OBSERVERS=OFF \
  -DUSE_OPENCL=OFF \
  -DUSE_OPENCV=ON \
  -DUSE_OPENMP=OFF \
  -DUSE_PROF=OFF \
  -DUSE_PYTORCH_QNNPACK=OFF \
  -DUSE_QNNPACK=ON \
  -DUSE_REDIS=OFF \
  -DUSE_ROCKSDB=ON \
  -DUSE_ROCM=OFF \
  -DUSE_SNPE=OFF \
  -DUSE_SYSTEM_EIGEN_INSTALL=OFF \
  -DUSE_TBB=OFF \
  -DUSE_TENSORRT=OFF \
  -DUSE_ZMQ=ON \
  -DUSE_ZSTD=OFF \
  -DHAVE_STD_REGEX=0 \
  -DHAVE_POSIX_REGEX=0 \
  -DHAVE_STEADY_CLOCK=0 \
  -DATEN_THREADING=NATIVE \
  -DBLAS=OpenBLAS \
  -DCMAKE_CROSSCOMPILING=ON \
  -DNATIVE_BUILD_DIR=$LIBTORCH_ROOT/third_party/sleef/host_build/ \
  -DCMAKE_CXX_FLAGS="-L$LIBTORCH_DEPENDENCIES/lib -llmdb -lleveldb -lsnappy -lopencv_core -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc -lopencv_video -lopencv_videoio -lzmq -lrocksdb"

cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE VERBOSE=1

# (Opt.) Compile vision library
if false; then
cd $WORKING_DIR/

PYTORCH_VISION_VERSION_MAJOR=0
PYTORCH_VISION_VERSION_MINOR=8
PYTORCH_VISION_VERSION_PATCH=2
PYTORCH_VISION="vision-\
$PYTORCH_VISION_VERSION_MAJOR"."\
$PYTORCH_VISION_VERSION_MINOR"."\
$PYTORCH_VISION_VERSION_PATCH"
PYTORCH_VISION_URL="https://github.com/pytorch/vision/archive/refs/tags/v\
$PYTORCH_VISION_VERSION_MAJOR"."\
$PYTORCH_VISION_VERSION_MINOR"."\
$PYTORCH_VISION_VERSION_PATCH".tar.gz

wget $PYTORCH_VISION_URL
tar -xvf $WORKING_DIR/v$PYTORCH_VISION_VERSION_MAJOR.$PYTORCH_VISION_VERSION_MINOR.$PYTORCH_VISION_VERSION_PATCH.tar.gz
rm *.tar.gz
yes | cp -rf $WORKING_DIR/$PYTORCH_VISION-patch/. $WORKING_DIR/$PYTORCH_VISION/.
cd $WORKING_DIR/$PYTORCH_VISION/
mkdir aarch64_build
cd aarch64_build/
cmake .. -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=$WORKING_DIR/$PYTORCH_TOOLCHAIN \
  -DCMAKE_INSTALL_PREFIX=$TORCHVISION \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=$LIBTORCH_DEPENDENCIES \
  -DTorch_DIR=$LIBTORCH_PREFIX/share/cmake/Torch \
  -DUSE_PYTHON=OFF \
  -DWITH_CUDA=OFF \
  -DPNG_LIBRARY=$LIBTORCH_DEPENDENCIES/lib/libopencv_imgcodecs.so \
  -DJPEG_LIBRARY=$LIBTORCH_DEPENDENCIES/lib/libopencv_imgcodecs.so
cmake --build . \
  --config Release \
  --target install \
  -- -j$NUM_CORE
fi
