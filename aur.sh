#!/bin/bash -ux

targetDIR="$HOME/Apps"
package="${1}"
installDIR=$(echo $package | awk -F/ '{print $NF}' | awk -F\. '{print $1}')

cd "${targetDIR}" || exit 1
git clone "${package}"
cd "${installDIR}" || exit 1
makepkg -s

for target in *.tar.zst ; do
    sudo pacman -U "${target}"
done
