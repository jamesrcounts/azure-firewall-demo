#!/usr/bin/env bash
set -euox pipefail

export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y nginx