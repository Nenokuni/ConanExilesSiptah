#!/bin/bash

# Template copy.
cp /tmp/Engine.ini $INSTALL_DIR/server/ConanSandbox/Saved/Config/WindowsServer/Engine.ini
cp /tmp/Game.ini $INSTALL_DIR/server/ConanSandbox/Saved/Config/WindowsServer/Game.ini
cp /tmp/ServerSettings.ini $INSTALL_DIR/server/ConanSandbox/Saved/Config/WindowsServer/ServerSettings.ini

# Replace.
sed -i "s#ServerName=SERVER_NAME#ServerName=$SERVER_NAME#" $INSTALL_DIR/server/ConanSandbox/Saved/Config/WindowsServer/Engine.ini
sed -i "s#RconPassword=RCON_PASSWORD#RconPassword=$RCON_PASSWORD#" $INSTALL_DIR/server/ConanSandbox/Saved/Config/WindowsServer/Game.ini
sed -i "s#AdminPassword=ADMIN_PASSWORD#AdminPassword=$ADMIN_PASSWORD#" $INSTALL_DIR/server/ConanSandbox/Saved/Config/WindowsServer/ServerSettings.ini
sed -i "s#ServerMessageOfTheDay=SERVER_MESSAGE#ServerMessageOfTheDay=$SERVER_MESSAGE#" $INSTALL_DIR/server/ConanSandbox/Saved/Config/WindowsServer/ServerSettings.ini
