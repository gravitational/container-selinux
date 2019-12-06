FROM registry.centos.org/centos/centos:7

RUN set -x && yum -y install \
	selinux-policy-devel \
	bzip2 \
	make

RUN mkdir -p /src

ADD .bashrc /root/.bashrc

WORKDIR "/src"
VOLUME ["/src"]
