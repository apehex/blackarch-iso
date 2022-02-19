#!/bin/bash

# init
SOURCEDIR="`dirname $(realpath ${0})`"
WORKDIR="`mktemp -d`/custom-iso"
BUNDLE="${1:-slim-iso}"
ARCH="x86_64"
# _GROUPS="`pacman -Sg | grep blackarch- | sort -u | tr -s '\n' ' '`"

# copy the target profile
cp -r "${SOURCEDIR}/../${BUNDLE}/" "${WORKDIR}" 

# discard packages
grep -Fxvf "${SOURCEDIR}/packages.${ARCH}.discard" "${SOURCEDIR}/../${BUNDLE}/packages.${ARCH}" > "${WORKDIR}/packages.${ARCH}.tmp"

# add packages
cat "${SOURCEDIR}/packages.${ARCH}.add" "${WORKDIR}/packages.${ARCH}.tmp" | sort -u | grep -v "###" > "${WORKDIR}/packages.${ARCH}"

# import dotfiles

# clone tools

# remove temp files
rm "${WORKDIR}/packages.${ARCH}.tmp"
