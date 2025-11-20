FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Install Python 3.8 and 3.10
RUN apt update && apt install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt update \
    && apt install -y python3.8 python3.8-venv python3.8-distutils \
                      python3.10 python3.10-venv python3.10-distutils \
    && apt clean

# Install CUDA 11.7 toolkit (userspace only)
# ... add commands to install CUDA 11.7 toolkit as you did

# Install cuDNN 8
RUN apt install -y libcudnn8 libcudnn8-dev

# Install PyTorch 2.0.1 + cu117
RUN python3.10 -m venv /venv310 && \
    /venv310/bin/pip install --upgrade pip && \
    /venv310/bin/pip install torch==2.0.1+cu117 torchvision==0.15.2+cu117 \
        torchaudio==2.0.2 --extra-index-url https://download.pytorch.org/whl/cu117
