# Base image: CUDA 11.7 + cuDNN 8 (runtime variant)
FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

# Set the timezone to avoid interactive prompts
ENV TZ=America/New_York
RUN apt-get update && apt-get install -y \
    tzdata && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Install dependencies (python, pip, curl, etc.)
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    curl \
    python3.8 python3.8-dev python3.8-venv \
    python3-pip \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA manually for Python 3.10 and install Python 3.10
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    curl -fsSL https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-dev python3.10-venv && \
    rm -rf /var/lib/apt/lists/*

# Set python3.10 as the default python
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# Upgrade pip for both Python versions
RUN python3.10 -m pip install --upgrade pip
RUN python3.8 -m pip install --upgrade pip

# Create virtual environments for PyTorch 2.0 versions
RUN python3.10 -m venv /env_torch200
RUN /env_torch200/bin/pip install torch==2.0.0+cu117 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

RUN python3.10 -m venv /env_torch201
RUN /env_torch201/bin/pip install torch==2.0.1+cu117 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

# Add virtualenvs to PATH (optional)
ENV PATH="/env_torch200/bin:/env_torch201/bin:$PATH"

# Set default command
CMD ["bash"]
