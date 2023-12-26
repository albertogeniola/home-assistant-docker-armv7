FROM --platform=linux/arm/v7 python:3.11-alpine3.17

# environment settings
ENV \
    HAVERSION="2023.10.3" \
    PIPFLAGS="--no-cache-dir --use-deprecated=legacy-resolver" \
    PYTHONPATH="${PYTHONPATH}:/pip-packages" \ 
    CARGO_NET_GIT_FETCH_WITH_CLI=true
    
# necessary args to compile grpcio on arm32v7
ARG GRPC_BUILD_WITH_BORING_SSL_ASM=false
ARG GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=true 
ARG GRPC_PYTHON_BUILD_WITH_CYTHON=true 
ARG GRPC_PYTHON_DISABLE_LIBC_COMPATIBILITY=true

# install packages
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    autoconf \
    ca-certificates \
    cargo \
    cmake \
    cups-dev \
    eudev-dev \
    ffmpeg-dev \
    gcc \
    glib-dev \
    g++ \
    jq \
    libffi-dev \
    jpeg-dev \
    libxml2-dev \
    libxslt-dev \
    make \
    openblas \
    openblas-dev \
    postgresql-dev \
    unixodbc-dev \
    git \
    unzip && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    bluez \
    bluez-deprecated \
    bluez-libs \
    cups-libs \
    curl \
    eudev-libs \
    ffmpeg \
    iputils \
    libcap \
    libjpeg-turbo \
    libstdc++ \
    libxslt \
    mariadb-connector-c \
    mariadb-connector-c-dev \
    openssh-client \
    openssl \
    postgresql-libs \
    py3-pip \
    tiff
  
  
# make directories 
RUN echo "**** make directories ****" && \
    mkdir /config && \
    mkdir /homeassistant && \
    mkdir /homeassistant/homeassistant

# get HA requirements and constraints 
RUN echo "**** get HA requirements & constraints ****" && \
    wget -P homeassistant/ https://raw.githubusercontent.com/home-assistant/core/${HAVERSION}/requirements.txt && \
    wget -P homeassistant/ https://raw.githubusercontent.com/home-assistant/core/${HAVERSION}/requirements_all.txt && \
    wget -P homeassistant/homeassistant/ https://raw.githubusercontent.com/home-assistant/core/${HAVERSION}/homeassistant/package_constraints.txt

RUN echo "**** pip install packages ****" && \
    python3 -m ensurepip --upgrade && \
    pip3 install --target /pip-packages --no-cache-dir --upgrade \
        distlib && \
    pip3 install --no-cache-dir --upgrade \
        cython \
        "pip>=21.0" \
        pyparsing \
        setuptools \
        wheel

# pip install from requirements
RUN echo "**** pip install requirements ****" && \
    pip3 install ${PIPFLAGS} \
        -r homeassistant/requirements.txt
        
RUN echo "**** pip install requirments_all ****" && \
    pip3 install ${PIPFLAGS} \
        -r homeassistant/requirements_all.txt

# pip install HA
RUN echo "**** pip install HA ****" && \
    pip3 install homeassistant==${HAVERSION} && \
    echo "**** wrapping up ****"

# Set the working directory
VOLUME /config
# Expose the Home Assistant port (8123)
EXPOSE 8123
# Start Home Assistant
CMD ["hass", "--config", "/config"]
