FROM fedora

RUN set -x && dnf -y install \
	findutils \
	less \
	selinux-policy-devel \
	setools-console \
	bzip2 \
	make && \
	dnf clean all

RUN mkdir -p /src

ADD .bashrc /root/.bashrc

WORKDIR "/src"
VOLUME ["/src"]
