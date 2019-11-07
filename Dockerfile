FROM registry.centos.org/centos/centos:7

RUN yum -y install \
	selinux-policy-devel \
	bzip2 \
	make

RUN mkdir -p /src

WORKDIR "/src"
VOLUME ["/src"]
