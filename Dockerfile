# Pull ubuntu image
FROM ubuntu:20.04

# Set environment variables
ENV CONTAINER_VERSION=0.7 \
    ELDEWRITO_VERSION=0.6.1 \
    MTNDEW_CHECKSUM=496b9296239539c747347805e15d2540 \
    DISPLAY=:1 \
    WINEPREFIX="/wine" \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0

# Install temporary packages
RUN apt-get update && \
    apt-get install -y wget software-properties-common apt-transport-https cabextract && \
    adduser --disabled-password --home /home/container container



# Install Wine key and repository
RUN dpkg --add-architecture i386 && \
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    rm winehq.key && \
    add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' && \
    apt-get update

# Install Wine stable
RUN apt-get install -y --install-recommends winehq-stable

# Download winetricks from source
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x ./winetricks

# Install X virtual frame buffer and winbind
RUN apt-get install -y xvfb winbind

# Configure wine prefix
# WINEDLLOVERRIDES is required so wine doesn't ask any questions during setup
RUN Xvfb :1 -screen 0 320x240x24 & \
    WINEDLLOVERRIDES="mscoree,mshtml=" wineboot -u && \
    wineserver -w && \
    ./winetricks -q vcrun2012 winhttp

# Cleanup
RUN apt-get remove -y wget software-properties-common apt-transport-https cabextract && \
    rm -rf /var/lib/apt/lists/* && \
    rm winetricks && \
    rm -rf .cache/

# Set container user for Pterodactyl
USER container
ENV  USER=container HOME=/home/container

WORKDIR /home/container

# Add the entrypoint script
COPY ./entrypoint.sh /entrypoint.sh

# Set start command to execute the start script
CMD [ "/bin/bash", "/entrypoint.sh" ]
