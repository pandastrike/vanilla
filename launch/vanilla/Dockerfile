FROM base/archlinux
MAINTAINER David Harper (david@pandastrike.com)
#===============================================================================
# Vanilla
#===============================================================================
# This Dockerfile describes a Vanilla web server.

RUN pacman -Syu --noconfirm
RUN pacman-db-upgrade
RUN pacman -S --noconfirm jre7-openjdk-headless wget vim tmux git nodejs

# Install Vanilla
RUN git clone git://hook.dessert.cluster:2001/repos/vanilla.git vanilla

# Install CoffeeScript
RUN npm install -g coffee-script
