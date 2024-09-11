#!/bin/bash

packages="luarocks wget npm cargo tree-sitter"

echo "Installing $packages ..."

yay -Syu --needed --noconfirm $packages
