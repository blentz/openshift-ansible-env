#################################################
# Configurable settings
#################################################

# What ansible version to install
ANSIBLE_VERSION = 2.3.1.0

# Info to use in the .gitconfig
GIT_NAME = 'Brett Lentz'
GIT_EMAIL = 'blentz@redhat.com'

# The branch to use for installing roles
GIT_BRANCH = 'prod'

#################################################

# a spoonful of syntactic sugar makes the medicine go down...
.DEFAULT_GOAL := all

# check if git dir exists
ifeq ($(wildcard ./git),)
GIT_CLONED = 0
else
GIT_CLONED = 1
endif

# check if rpms dir exists
ifeq ($(wildcard ./rpms),)
RPMS_BUILT = 0
else
RPMS_BUILT = 1
endif

# TARGET: prep
# PURPOSE: prepares the build environment before the docker build
prep: rpms
	ANSIBLE_VERSION=$(ANSIBLE_VERSION) \
	GIT_BRANCH=$(GIT_BRANCH) \
		./bin/templater.sh Dockerfile.template > Dockerfile
	GIT_NAME=$(GIT_NAME) \
	GIT_EMAIL=$(GIT_EMAIL) \
		 ./bin/templater.sh files/gitconfig.template > files/gitconfig

# TARGET: gitclone
# REQUIRES: git repository access
# PURPOSE: clones the openshift git repositories.
gitclone:
ifeq ($(GIT_CLONED), 0)
	./bin/git-clone-repos.sh
else
	@echo "Git repos already cloned."
endif

# TARGET: rpms
# REQUIRES: openshift-tools git repository access
# PURPOSE: builds the openshift-tools RPMs
rpms: gitclone
ifeq ($(RPMS_BUILT), 0)
	./bin/build-rpms.sh
else
	@echo "RPMs already built."
endif

# TARGET: build
# PURPOSE: builds the docker container
build:
	docker build -t ansible-$(ANSIBLE_VERSION):${USERNAME} .

# TARGET: all
# PURPOSE: enables end-to-end build
all: prep build

.PHONY: clean cleanrpms cleangit realclean

# TARGET: clean
# PURPOSE: remove templated files
clean:
	rm -f Dockerfile files/gitconfig

# TARGET: cleanrpms
# PURPOSE: remove built RPMs
cleanrpms:
	rm -rf rpms

# TARGET: cleangit
# PURPOSE: remove git repos
cleangit:
	rm -rf git

# TARGET: realclean
# PURPOSE: nuke everything. it's the only way to be sure.
realclean: clean cleanrpms cleangit
