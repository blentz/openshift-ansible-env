.DEFAULT_GOAL := all

ANSIBLE_VERSION = 2.3.1.0
# ANSIBLE_VERSION = '2.2.3.0'

GIT_NAME = 'Brett Lentz'
GIT_EMAIL = 'blentz@redhat.com'

ifneq ("$(wildcard $(./git))","")
GIT_CLONED = 1
else
GIT_CLONED = 0
endif

prep: repoclone
	ANSIBLE_VERSION=$(ANSIBLE_VERSION) \
		./bin/templater.sh Dockerfile.template > Dockerfile
	GIT_NAME=$(GIT_NAME) GIT_EMAIL=$(GIT_EMAIL) \
		 ./bin/templater.sh files/gitconfig.template > files/gitconfig

repoclone:
ifeq (GIT_CLONED, 0)
	./bin/git-clone-repos.sh
else
	@echo "Git repos already cloned."
endif

build:
	docker build -t ansible-$(ANSIBLE_VERSION):${USERNAME} .

all: prep build

.PHONY: clean realclean
clean:
	rm -f Dockerfile files/gitconfig

realclean: clean
	rm -rf git
