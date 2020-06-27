FROM scratch
ADD archlinux.tar /
ENV LANG=en_US.UTF-8
RUN pacman-key --init && pacman-key --populate archlinux
CMD ["/usr/bin/bash"]
