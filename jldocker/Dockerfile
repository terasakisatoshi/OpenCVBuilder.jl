FROM julia:1.5.3

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    python3 \
    python3-distutils \
    python3-numpy \
    libgtk2.0-dev \
    pkg-config \
    git \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

RUN git clone https://github.com/JuliaInterop/libcxxwrap-julia.git && \
    cmake -DJulia_EXECUTABLE=`which julia` -S libcxxwrap-julia -B libcxxwrap-julia-build && \
    cmake --build libcxxwrap-julia-build --config Release -j ${nproc} && \
    cmake --build libcxxwrap-julia-build --target install && \
    rm -r libcxxwrap-julia libcxxwrap-julia-build # clean up

RUN julia -e 'using Pkg; Pkg.add("CxxWrap"); Pkg.precompile()' && \
    git clone --depth=1 -b 4.5.0 https://github.com/opencv/opencv.git && \
    git clone --depth=1 -b 4.5.0 https://github.com/opencv/opencv_contrib.git && \
    mkdir build && \
    cmake -S ./opencv -B build \
          -DJlCxx_DIR=/usr/local/lib/cmake/JlCxx \
          -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
          -DWITH_JULIA=ON \
          -DWITH_GTK=ON \
          ../opencv && \
    cmake --build ./build --config Release -j ${nproc} && \
    cp -r ./build/OpenCV ~/.julia/packages/ && \
    cmake --build ./build --target install && \
    rm -r ./build ./opencv opencv_contrib # clean up

# smoke test
RUN julia -e 'using Pkg; pkg"dev ~/.julia/packages/OpenCV"; Pkg.precompile(); using OpenCV'
