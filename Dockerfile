FROM gitpod/workspace-base

USER root

COPY create-overlay runonce /usr/bin/

RUN curl -o /usr/bin/fuse-overlayfs \
    -L https://github.com/containers/fuse-overlayfs/releases/download/v1.11/fuse-overlayfs-x86_64 \
    && chmod +x /usr/bin/fuse-overlayfs

RUN rc=/etc/bash.bashrc; if test -e $rc; then sed -i '1s/^/runonce\n/' $rc; else echo "runonce" > $rc; fi \
    && mkdir -m 0777 -p $HOME/.runonce


USER gitpod

# Persist ~/ (HOME)
RUN echo 'create-overlay $HOME' > "$HOME/.runonce/1-home_persist"