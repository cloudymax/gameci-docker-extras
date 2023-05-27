ARG EDITOR_IMAGE="unityci/editor:ubuntu-2022.2.20f1-webgl-1"

FROM $EDITOR_IMAGE

ARG USER="player1"
ARG DRIVER_VERSION="525.116.04"
ENV OLD_SSL_DEB="http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb"

# Install deps for Nvidia and Desktop
RUN apt-get update && \
  apt-get install -y kmod \
  sudo \
  pkg-config \
  make \
  libvulkan1 \
  dbus \
  dbus-x11 \
  tmux \
  x11vnc \
  xvfb \
  xorg \
  htop \
  xfce4 && \
  wget ${OLD_SSL_DEB} && \
  dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
  rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
  wget -O /driver.run "https://us.download.nvidia.com/XFree86/Linux-x86_64/$DRIVER_VERSION/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run" && \
  sh /driver.run -x

# create a user for non-root operation
RUN useradd -ms /bin/bash $USER && \
        usermod -aG sudo $USER && \
        echo 'player1 ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
        wget $OLD_SSL_DEB && \
        dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb && \
        rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb

RUN rm /usr/bin/unity-editor && \
        ln -s /opt/unity/Editor/Unity /usr/bin/unity-editor && \
        mkdir -p /home/$USER/.local/bin && \
        mkdir -p /home/$USER/.local/lib && \
        chown $USER:$USER /home/$USER/.local/bin && \
        chown $USER:$USER /home/$USER/.local/lib && \
        mv /driver.run /home/$USER/driver.run

# Swap to user account
USER $USER
WORKDIR /home/$USER/