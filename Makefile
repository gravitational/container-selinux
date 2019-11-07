TARGETS?=container
MODULES?=${TARGETS:=.pp.bz2}
SHAREDIR?=/usr/share
DOCKER_ARGS?=
BUILDBOX?=selinux-dev
BUILDBOX_INSTANCE?=selinux-dev
CONTAINER_RUNTIME:=$(shell command -v podman 2> /dev/null || echo docker)

all: ${TARGETS:=.pp.bz2}

%.pp.bz2: %.pp
	@echo Compressing $^ -\> $@
	bzip2 -9 $^

%.pp: %.te
	make -f ${SHAREDIR}/selinux/devel/Makefile $@

clean:
	rm -f *~  *.tc *.pp *.pp.bz2
	rm -rf tmp *.tar.gz

man: install-policy
	sepolicy manpage --path . --domain ${TARGETS}_t

install-policy: all
	semodule -i ${TARGETS}.pp.bz2

install: man
	install -D -m 644 ${TARGETS}.pp.bz2 ${DESTDIR}${SHAREDIR}/selinux/packages/container.pp.bz2
	install -D -m 644 container.if ${DESTDIR}${SHAREDIR}/selinux/devel/include/services/container.if
	install -D -m 644 container_selinux.8 ${DESTDIR}${SHAREDIR}/man/man8/

.PHONY: build
build: buildbox
	${CONTAINER_RUNTIME} run --name=${LIBPOD_INSTANCE} --privileged -v ${PWD}:/src --rm ${BUILDBOX} make all

.PHONY: buildbox
buildbox:
	${CONTAINER_RUNTIME} build -t ${BUILDBOX} .
