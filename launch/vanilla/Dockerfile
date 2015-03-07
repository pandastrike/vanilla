FROM base/archlinux
MAINTAINER David Harper (david@pandastrike.com)
#===============================================================================
# Vanilla Example - Dockerfile
#===============================================================================
# This Dockerfile describes a container holding the "hello world" Node server
# that is part of the Huxley Vanilla example.

RUN pacman -Syu --noconfirm
RUN pacman-db-upgrade
RUN pacman -S --noconfirm jre7-openjdk-headless wget vim tmux git nodejs

# Install Vanilla
RUN git clone git://hook.flavor.cluster:2001/repos/vanilla.git vanilla

# Install CoffeeScript
RUN npm install -g coffee-script
