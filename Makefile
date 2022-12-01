ROOT = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
include $(ROOT)/Makefile.vars.repo
include $(ROOT)/Makefile.vars.version
include $(ROOT)/Makefile.vars.system
export

hello:
	@echo "hello shell tools!"
	@echo "os: ${OS}"
	@echo "installer: ${INSTALLER}"

zsh:
	bash ./system/install-zsh.sh

java:
	bash ./dev/install-java.sh

python3:
	bash ./dev/install-python.sh

golang:
	bash ./dev/install-golang.sh

nodejs:
	bash ./dev/install-nodejs.sh