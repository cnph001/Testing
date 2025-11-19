# Base image: CUDA 11.7 + cuDNN 8, developer toolkit (nvcc included)
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Make apt non-interactive to avoid tzdata prompt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# --- Layer 1: System Setup and Python Installation ---
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    curl \
    tzdata \
    # Install both Python 3.8 and 3.9
    python3.8 python3.8-dev python3.8-venv \
    python3.9 python3.9-dev python3.9-venv \
    python3-pip \
    # Set timezone
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    # Clean up APT cache to keep the image small
    && rm -rf /var/lib/apt/lists/*

# --- Layer 2: Python Configuration and Pip Upgrade ---
# Configure python alternatives (3.9 is default 'python3', but we'll use 'python3.8' explicitly below)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 \
    # Upgrade pip for both versions
    && python3.9 -m pip install --upgrade pip \
    && python3.8 -m pip install --upgrade pip

# --- Layer 3: PyTorch 2.0.0 Environment (using Python 3.8) ---
# FIX: Use PyTorch index as the primary index for reliable CUDA wheel install.
RUN python3.8 -m venv /env_torch200_py38 \
    && /env_torch200_py38/bin/pip install \
    'torch==2.0.0' 'torchvision' 'torchaudio' \
    --index-url https://download.pytorch.org/whl/cu117

# --- Layer 4: PyTorch 2.0.1 Environment (using Python 3.8) ---
# FIX: Use PyTorch index as the primary index for reliable CUDA wheel install.
RUN python3.8 -m venv /env_torch201_py38 \
    && /env_torch201_py38/bin/pip install \
    'torch==2.0.1' 'torchvision' 'torchaudio' \
    --index-url https://download.pytorch.org/whl/cu117

# --- Final Configuration ---
# Add virtualenvs to PATH for easy access
ENV PATH="/env_torch200_py38/bin:/env_torch201_py38/bin:$PATH"

# Default command
CMD ["bash"]
