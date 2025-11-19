# Base image: CUDA 11.7 + cuDNN 8, developer toolkit (nvcc included)
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    curl \
    python3.8 python3.8-dev python3.8-venv \
    python3.10 python3.10-dev python3.10-venv \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Set alternatives for python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# Upgrade pip
RUN python3.10 -m pip install --upgrade pip
RUN python3.8 -m pip install --upgrade pip

# Create virtual environments for PyTorch versions
RUN python3.10 -m venv /env_torch200
RUN /env_torch200/bin/pip install torch==2.0.0+cu117 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

RUN python3.10 -m venv /env_torch201
RUN /env_torch201/bin/pip install torch==2.0.1+cu117 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

# Add virtualenvs to PATH (optional)
ENV PATH="/env_torch200/bin:/env_torch201/bin:$PATH"

# Default command
CMD ["bash"]
