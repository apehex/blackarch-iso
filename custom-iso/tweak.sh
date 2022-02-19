#!/bin/bash

# init
SOURCEDIR="`dirname $(realpath ${0})`"
WORKDIR="`mktemp -d`"
BUNDLE="${1:-slim-iso}"
ARCH="x86_64"
# _GROUPS="`pacman -Sg | grep blackarch- | sort -u | tr -s '\n' ' '`"

# discard packages
grep -Fxvf "${SOURCEDIR}/packages.${ARCH}.discard" "${SOURCEDIR}/../${BUNDLE}/packages.${ARCH}" > "${WORKDIR}/packages.${ARCH}.tmp"

# add packages
cat "${SOURCEDIR}/packages.${ARCH}.add" "${WORKDIR}/packages.${ARCH}.tmp" > "${WORKDIR}/packages.${ARCH}"

# remove comments

# remove temp files
rm "${WORKDIR}/packages.${ARCH}.tmp"
