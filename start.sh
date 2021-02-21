#!/bin/bash
screen -d -m -S conan xvfb-run --auto-servernum --server-args="-screen 0 640x480x24:32" wine64 $INSTALL_DIR/server/ConanSandbox/Binaries/Win64/ConanSandboxServer-Win64-Test.exe -QueryPort=27015 -nosteamclient -game -server -log -MULTIHOME=$(hostname -I | cut -f1 -d" ")
