#!/bin/sh
set -e

script_dir=$(dirname "$(realpath "$0")")
ln -sfn "$script_dir" ~/.nix-config
echo "Created symbolic link: ~/.nix-config → $script_dir"