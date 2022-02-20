#!/bin/bash

# init
SOURCEDIR="`dirname $(realpath ${0})`"
WORKDIR="`mktemp -d`/custom-iso"
DOTDIR="${HOME}/workspace/homesick/dotfiles/home"
BUNDLE="${1:-slim-iso}"
ARCH="x86_64"

# copy the target profile
cp -r "${SOURCEDIR}/../${BUNDLE}/" "${WORKDIR}" 

# discard packages
grep -Fxvf "${SOURCEDIR}/packages.${ARCH}.discard" "${SOURCEDIR}/../${BUNDLE}/packages.${ARCH}" > "${WORKDIR}/packages.${ARCH}.tmp"

# add packages
cat "${SOURCEDIR}/packages.${ARCH}.add" "${WORKDIR}/packages.${ARCH}.tmp" | sort -u | grep -v "###" > "${WORKDIR}/packages.${ARCH}"

# adding files (user dir)
rsync -avh --update --progress "${SOURCEDIR}/airootfs/" "${WORKDIR}/airootfs/"

# import dotfiles
rsync -avh --progress --update "${DOTDIR}/" "${WORKDIR}/airootfs/etc/skel/.dotfiles/"

# Link the user dotfiles
for filename in "${WORKDIR}/airootfs/etc/skel/.dotfiles/"* ; do
    stow --dir="${WORKDIR}/airootfs/etc/skel/.dotfiles" --target="${WORKDIR}/airootfs/etc/skel" --restow "$(basename $filename)"
done

# clone tools

# remove temp files
rm "${WORKDIR}/packages.${ARCH}.tmp"
rm "${WORKDIR}/airootfs/etc/skel/.gitkeep"
