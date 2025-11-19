# Base image: CUDA 11.7 + cuDNN 8, developer toolkit (nvcc included)
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Make apt non-interactive and set timezone
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# --- Layer 1: System Setup and Python Installation ---
# Install necessary dependencies and add repository for Python 3.10
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    curl \
    tzdata \
    apt-transport-https \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y \
    python3.8 python3.8-dev python3.8-venv \
    python3.10 python3.10-dev python3.10-venv \
    python3-pip \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    # Clean up APT cache to keep the image small
    && rm -rf /var/lib/apt/lists/*

# --- Layer 2: Python Alternatives and Pip Upgrade ---
# Set Python 3.10 as the default 'python3' for convenience
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    # Upgrade pip for both required versions
    && python3.10 -m pip install --upgrade pip \
    && python3.8 -m pip install --upgrade pip

# --- Layer 3: Virtual Environments for Python 3.8 ---
# Create and install PyTorch 2.0.0 and 2.0.1 in Python 3.8
RUN python3.8 -m venv /env_py38_torch200 \
    && /env_py38_torch200/bin/pip install \
    'torch==2.0.0' 'torchvision==0.15.2' 'torchaudio==2.0.2' \
    --index-url https://download.pytorch.org/whl/cu117 \
    && python3.8 -m venv /env_py38_torch201 \
    && /env_py38_torch201/bin/pip install \
    'torch==2.0.1' 'torchvision==0.15.2' 'torchaudio==2.0.2' \
    --index-url https://download.pytorch.org/whl/cu117

# --- Layer 4: Virtual Environments for Python 3.10 ---
# Create and install PyTorch 2.0.0 and 2.0.1 in Python 3.10
RUN python3.10 -m venv /env_py310_torch200 \
    && /env_py310_torch200/bin/pip install \
    'torch==2.0.0' 'torchvision==0.15.2' 'torchaudio==2.0.2' \
    --index-url https://download.pytorch.org/whl/cu117 \
    && python3.10 -m venv /env_py310_torch201 \
    && /env_py310_torch201/bin/pip install \
    'torch==2.0.1' 'torchvision==0.15.2' 'torchaudio==2.0.2' \
    --index-url https://download.pytorch.org/whl/cu117

# --- Final Configuration ---
# Add all environment bins to PATH for easy access
ENV PATH="/env_py38_torch200/bin:/env_py38_torch201/bin:/env_py310_torch200/bin:/env_py310_torch201/bin:$PATH"

# Default command
CMD ["bash"]
