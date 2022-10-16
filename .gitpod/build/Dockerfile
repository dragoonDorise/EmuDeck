FROM manjarolinux/base

RUN pacman -Syu --noconfirm --needed \
    git \
    git-lfs \
    docker \
    sudo \
    base-devel

### Gitpod user ###
### Minor Modifications have been made ###

# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G wheel -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%wheel\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%wheel ALL=NOPASSWD:ALL/g' /etc/sudoers \
    && echo "gitpod ALL = NOPASSWD : ALL" >> /etc/sudoers \
    # To emulate the workspace-session behavior within dazzle build env
    && mkdir /workspace && chown -hR gitpod:gitpod /workspace \
    && mkdir -p $HOME/.config/EmuDeck/backend

ENV HOME=/home/gitpod
WORKDIR $HOME/.config/EmuDeck/backend
# custom Bash prompt
RUN { echo && echo "PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\$(__git_ps1 \" (%s)\") $ '" ; } >> .bashrc

### Gitpod user (2) ###
USER gitpod
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success" && \
    # create .bashrc.d folder and source it in the bashrc
    mkdir -p /home/gitpod/.bashrc.d && \
    (echo; echo "for i in \$(ls -A \$HOME/.bashrc.d/); do source \$HOME/.bashrc.d/\$i; done"; echo) >> /home/gitpod/.bashrc && \
    # create a completions dir for gitpod user
    mkdir -p /home/gitpod/.local/share/bash-completion/completions

# configure git-lfs
RUN sudo git lfs install --system

# add yay for aur
RUN sudo su gitpod -c cd /tmp && \
    git clone https://aur.archlinux.org/yay-bin && \
    cd yay-bin && \
    makepkg -si --noconfirm
RUN sudo su gitpod -c "yay -Syu --noconfirm neofetch"

### Input Your Environment and packages here

RUN sudo su gitpod -c "yay -S flatpak flatpak-builder --noconfirm"