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

# remove unwanted files
rm -rf "${WORKDIR}/airootfs/etc/skel/*"

# tweak post install hook
perl -pi -e "s#'lightdm.service' ##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#'NetworkManager' ##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#'irqbalance' ##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#cp /usr/share/blackarch/config/bash/bashrc /etc/skel/.bashrc##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#cp /usr/share/blackarch/config/bash/bash_profile /etc/skel/.bash_profile##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#cp /usr/share/blackarch/config/zsh/zshrc /etc/skel/.zshrc##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#useradd -m -g users -G wheel,power,audio,video,storage -s /bin/zsh liveuser##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e 's#echo "liveuser:blackarch" | chpasswd##gi' "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#cp -r /usr/share/blackarch/config/vim/vim /home/liveuser/.vim##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#cp /usr/share/blackarch/config/vim/vimrc /home/liveuser/.vimrc##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#ln -sf /usr/share/icons/blackarch-icons/apps/scalable/distributor-logo-blackarch.svg /home/liveuser/.face##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#mkdir -p /home/liveuser/Desktop##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#chown -R liveuser:users /home/liveuser/Desktop##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#chmod -R 755 /home/liveuser/Desktop##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#ln -sf /usr/share/applications/calamares.desktop /home/liveuser/Desktop/calamares.desktop#ln -sf /usr/share/applications/calamares.desktop /home/archie/.local/bin/calamares.desktop#gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#ln -sf /usr/share/applications/xfce4-terminal-emulator.desktop /home/liveuser/Desktop/terminal.desktop##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#chmod +x /home/liveuser/Desktop/*.desktop##gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"
perl -pi -e "s#liveuser#archie#gi" "${WORKDIR}/airootfs/root/customize_airootfs.sh"

# adding files (user dir)
rsync -avh --update --progress "${SOURCEDIR}/airootfs/" "${WORKDIR}/airootfs/"

# import dotfiles
rsync -avh --progress --update "${DOTDIR}/" "${WORKDIR}/airootfs/etc/skel/.dotfiles/"

# Link the user dotfiles
for filename in "${WORKDIR}/airootfs/etc/skel/.dotfiles/"* ; do
    stow --dir="${WORKDIR}/airootfs/etc/skel/.dotfiles" --target="${WORKDIR}/airootfs/etc/skel" --restow "$(basename $filename)"
done

# remove conflicting files
rm "${WORKDIR}/airootfs/etc/skel/.screenrc"

# clone tools

# remove temp files
rm "${WORKDIR}/packages.${ARCH}.tmp"
rm "${WORKDIR}/airootfs/etc/skel/.gitkeep"
