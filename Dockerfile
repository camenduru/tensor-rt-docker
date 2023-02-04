FROM nvcr.io/nvidia/tensorrt:22.10-py3

WORKDIR /content

RUN apt-get update
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:flexiondotorg/nvtop
RUN apt-get update
RUN apt-get install -y nvtop
RUN apt-get install -y tmux nano
RUN apt-get upgrade -y

RUN pip install pyxtermjs

RUN adduser --disabled-password --gecos '' user
RUN chown -R user:user /content
RUN chmod -R 777 /content
USER user

RUN git clone --branch release/8.5.1 --single-branch https://github.com/camenduru/TensorRT && \
    cd TensorRT && \
    git submodule update --init --recursive
    
RUN cd TensorRT && mkdir -p build && \
    cd build && \
    cmake /content/TensorRT -DTRT_OUT_DIR=$PWD/out && \
    cd plugin && \
    make -j$(nproc)

ENV PLUGIN_LIBS "/content/TensorRT/build/out/libnvinfer_plugin.so"
ENV TERM=xterm-256color

RUN pip install -r /content/TensorRT/demo/Diffusion/requirements.txt
RUN cd /content/TensorRT/demo/Diffusion && mkdir -p onnx engine output

EXPOSE 7860

CMD pyxtermjs -p 7860 --host 0.0.0.0
