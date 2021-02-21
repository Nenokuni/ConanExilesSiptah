#!/bin/bash
screen -d -m -S conan-update $STEAM_CMD_DIR/steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +force_install_dir $INSTALL_DIR/server +app_update 443030 +exit
