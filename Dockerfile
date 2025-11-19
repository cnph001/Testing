# Base image: CUDA 11.7 + cuDNN 8, developer toolkit (nvcc included)
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Make apt non-interactive to avoid tzdata prompt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install dependencies, Python 3.8, 3.9, and set timezone
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    curl \
    tzdata \
    python3.8 python3.8-dev python3.8-venv \
    python3.9 python3.9-dev python3.9-venv \
    python3-pip \
    # Set timezone
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    # Clean up APT cache to keep the image small
    && rm -rf /var/lib/apt/lists/*

# Configure python alternatives and upgrade pip for both versions (One Layer)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    && python3.9 -m pip install --upgrade pip \
    && python3.8 -m pip install --upgrade pip

# Create and install dependencies in PyTorch 2.0.0 virtual environment (One Layer)
RUN python3.9 -m venv /env_torch200 \
    && /env_torch200/bin/pip install \
    torch==2.0.0+cu117 torchvision torchaudio \
    --extra-index-url https://download.pytorch.org/whl/cu117

# Create and install dependencies in PyTorch 2.0.1 virtual environment (One Layer)
RUN python3.9 -m venv /env_torch201 \
    && /env_torch201/bin/pip install \
    torch==2.0.1+cu117 torchvision torchaudio \
    --extra-index-url https://download.pytorch.org/whl/cu117

# Add virtualenvs to PATH for easy access
ENV PATH="/env_torch200/bin:/env_torch201/bin:$PATH"

# Default command
CMD ["bash"]
