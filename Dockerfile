# Base image: CUDA 11.7 + cuDNN 8, developer toolkit (nvcc included)
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Make apt non-interactive to avoid tzdata prompt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install dependencies and Python 3.8 first
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    curl \
    tzdata \
    python3.8 python3.8-dev python3.8-venv \
    python3-pip \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.10 from source
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz && \
    tar xzf Python-3.10.9.tgz && \
    cd Python-3.10.9 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    rm -f /usr/src/Python-3.10.9.tgz

# Install pip and upgrade it
RUN python3.10 -m ensurepip --upgrade
RUN python3.10 -m pip install --upgrade pip

# Install the virtualenv package for Python 3.10
RUN python3.10 -m pip install virtualenv

# Create virtual environments for PyTorch versions
RUN python3.10 -m venv /env_torch200
RUN /env_torch200/bin/pip install torch==2.0.0+cu117 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

RUN python3.10 -m venv /env_torch201
RUN /env_torch201/bin/pip install torch==2.0.1+cu117 torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

# Add virtualenvs to PATH (optional)
ENV PATH="/env_torch200/bin:/env_torch201/bin:$PATH"

# Default command
CMD ["bash"]
