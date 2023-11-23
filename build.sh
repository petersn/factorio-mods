#!/bin/bash
set -x
set -e

rm -f OneItemForFree_0.0.4.zip
zip -r OneItemForFree_0.0.4.zip OneItemForFree_0.0.4/
cp OneItemForFree_0.0.4.zip ~/.factorio/mods/

rm -f MassiveMultiplayerAnyPercentTAS_0.0.1.zip
zip -r MassiveMultiplayerAnyPercentTAS_0.0.1.zip MassiveMultiplayerAnyPercentTAS_0.0.1/
cp MassiveMultiplayerAnyPercentTAS_0.0.1.zip ~/.factorio/mods/
