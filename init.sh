apt-get update
apt-get -y upgrade
apt-get update
apt-get -y install zsh emacs git vim chromium-browser virtualbox vagrant curl wget
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
cd /usr/src
wget https://raw.githubusercontent.com/getlantern/lantern-binaries/master/lantern-installer-beta-64-bit.deb
dpkg -i lantern-installer-beta-64-bit.deb
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
