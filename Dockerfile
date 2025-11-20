FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y python3.8 python3.8-venv python3.8-distutils \
                       python3.10 python3.10-venv python3.10-distutils \
                       libcudnn8 libcudnn8-dev \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3.10 -m venv /venv310 && \
    /venv310/bin/pip install --upgrade pip && \
    /venv310/bin/pip install torch==2.0.1+cu117 torchvision==0.15.2+cu117 \
        torchaudio==2.0.2 --extra-index-url https://download.pytorch.org/whl/cu117
