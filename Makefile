MODULES?=${TARGETS:=.pp.bz2}
SHAREDIR?=/usr/share
TARGETS?=$(OUTPUT)/container
BUILDBOX?=selinux-dev:centos8
BUILDBOX_INSTANCE?=selinux-dev
OUTPUT?=output
CONTAINER_RUNTIME:=$(shell command -v podman 2> /dev/null || echo docker)

all: build

$(OUTPUT)/%.pp.bz2: $(OUTPUT)/%.pp | $(OUTPUT)
	@echo Compressing $^ -\> $@
	bzip2 -f -9 -c $^ > $@

$(OUTPUT)/%.pp: %.te | $(OUTPUT)
	make -f ${SHAREDIR}/selinux/devel/Makefile $(@F)
	mv $(@F) $@

.PHONY: clean
clean:
	rm -f *~  *.tc *.pp *.pp.bz2
	rm -rf tmp *.tar.gz

.PHONY: man
man: install-policy
	sepolicy manpage --path . --domain ${TARGETS}_t

.PHONY: install-policy
install-policy: all
	semodule -i ${TARGETS}.pp.bz2

.PHONY: install
install: man
	install -D -m 644 ${TARGETS}.pp.bz2 ${DESTDIR}${SHAREDIR}/selinux/packages/container.pp.bz2
	install -D -m 644 container.if ${DESTDIR}${SHAREDIR}/selinux/devel/include/services/container.if
	install -D -m 644 container_selinux.8 ${DESTDIR}${SHAREDIR}/man/man8/container_selinux.8
	install -D -m 644 container_contexts ${DESTDIR}${SHAREDIR}/containers/continer_contexts

.PHONY: build
build: buildbox
	${CONTAINER_RUNTIME} run \
		--name=${BUILDBOX_INSTANCE} \
		--privileged \
		-v ${PWD}:/src \
		--rm ${BUILDBOX} \
		make ${TARGETS:=.pp.bz2}

.PHONY: buildbox
buildbox:
	${CONTAINER_RUNTIME} build -t ${BUILDBOX} -f Dockerfile .

$(OUTPUT):
	mkdir -p $@
