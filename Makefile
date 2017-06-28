.DEFAULT_GOAL := all

ANSIBLE_VERSION = 2.3.1.0
# ANSIBLE_VERSION = '2.2.3.0'

GIT_NAME = 'Brett Lentz'
GIT_EMAIL = 'blentz@redhat.com'

prep:
	ANSIBLE_VERSION=$(ANSIBLE_VERSION) \
		./bin/templater.sh Dockerfile.template > Dockerfile
	GIT_NAME=$(GIT_NAME) GIT_EMAIL=$(GIT_EMAIL) \
		 ./bin/templater.sh files/gitconfig.template > files/gitconfig

	./bin/git-clone-repos.sh
build:
	docker build -t ansible-$(ANSIBLE_VERSION):${USERNAME} .

all: clean prep build

.PHONY: clean
clean:
	rm -f Dockerfile files/gitconfig
	rm -rf git
