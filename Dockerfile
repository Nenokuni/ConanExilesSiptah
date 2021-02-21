FROM debian:buster-slim

ENV USER_HOME /home/conan
ENV INSTALL_DIR /conan
ENV STEAM_CMD_DIR $INSTALL_DIR/steamcmd
ENV LC_ALL ja_JP.UTF-8

ARG user=conan
ARG group=conan
ARG uid=33333
ARG gid=33333
RUN mkdir -p $(dirname $USER_HOME) \
    && groupadd -g ${gid} ${group} \
    && useradd -d "$USER_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN mkdir -p $INSTALL_DIR
RUN set -x \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        psmisc \
        sqlite3 \
        task-japanese \
        locales \
        locales-all \
        procps \
        vim \
        xvfb \
        xauth \
        screen \
        gnupg \
        gnupg2 \
        software-properties-common \
        lib32stdc++6=8.3.0-6 \
        lib32gcc1=1:8.3.0-6 \
        wget=1.20.1-1.1 \
        ca-certificates \
    && echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen ja_JP.UTF-8 \
    && dpkg-reconfigure locales \
    && /usr/sbin/update-locale LANG=ja_JP.UTF-8 \
    && wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | apt-key add - \
    && echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | tee /etc/apt/sources.list.d/wine-obs.list \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && mkdir -p $STEAM_CMD_DIR \
    && cd $STEAM_CMD_DIR \
    && wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf - \
    && apt-get clean autoclean \
    && apt-get autoremove -y

WORKDIR $INSTALL_DIR

RUN mkdir server
RUN $STEAM_CMD_DIR/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir $INSTALL_DIR/server +login anonymous +app_update 443030 validate +exit
RUN chown -R ${user}:${user} $INSTALL_DIR

COPY Saved/Config/WindowsServer/Engine.ini /tmp/Engine.ini
COPY Saved/Config/WindowsServer/Game.ini /tmp/Game.ini
COPY Saved/Config/WindowsServer/ServerSettings.ini /tmp/ServerSettings.ini
RUN chown ${user}:${user} /tmp/Engine.ini
RUN chown ${user}:${user} /tmp/Game.ini
RUN chown ${user}:${user} /tmp/ServerSettings.ini

COPY Saved/Config $INSTALL_DIR/server/ConanSandbox/Saved/Config
COPY Saved/blacklist.txt $INSTALL_DIR/server/ConanSandbox/Saved/blacklist.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
RUN chown ${user}:${user} /entrypoint.sh

COPY start.sh /start.sh
RUN chmod 755 /start.sh
RUN chown ${user}:${user} /start.sh

COPY update.sh /update.sh
RUN chmod 755 /update.sh
RUN chown ${user}:${user} /update.sh

COPY kill.sh /kill.sh
RUN chmod 755 /kill.sh
RUN chown ${user}:${user} /kill.sh

RUN chown -R ${user}:${user} $INSTALL_DIR/server/ConanSandbox/Saved
RUN chown ${user}:${user} $INSTALL_DIR/server/ConanSandbox/Saved/blacklist.txt

USER ${user}
EXPOSE 7777/udp 7778/udp 27015/udp 25575/tcp
