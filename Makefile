NAME=consul
VERSION=0.8.1
ITERATION=1.lru
PREFIX=/usr/local/bin
LICENSE=BSD
VENDOR="Hashicorp"
MAINTAINER="Ryan Parman"
DESCRIPTION="Service discovery and configuration made easy. Distributed, highly available, and datacenter-aware."
URL=http://consul.io
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)

define AFTER_INSTALL
id -u consul &>/dev/null || useradd --system --user-group consul
mkdir -p /var/consul /etc/consul.d/server
chown -f consul:consul /var/consul /etc/consul.d/server
chmod -f 0755 /var/consul /etc/consul.d/server
endef

define AFTER_REMOVE
rm -Rf /var/consul /etc/consul.d/server
userdel consul
endef

export AFTER_INSTALL
export AFTER_REMOVE

#-------------------------------------------------------------------------------

all: info clean compile package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* consul* after*.sh

#-------------------------------------------------------------------------------

.PHONY: compile
compile:
	wget -O consul.zip https://releases.hashicorp.com/consul/$(VERSION)/consul_$(VERSION)_linux_amd64.zip
	unzip consul.zip

	echo "$$AFTER_INSTALL" > after-install.sh
	echo "$$AFTER_REMOVE" > after-remove.sh

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-m $(MAINTAINER) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix $(PREFIX) \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrfile 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-auto-add-directories \
		--template-scripts \
		--after-install after-install.sh \
		--after-remove after-remove.sh \
		consul \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo/
