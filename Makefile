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

lvim:
	bash ./system/install-lvim.sh

java:
	bash ./dev/install-java.sh

java-new:
	bash ./dev/install-java-new.sh

maven:
	bash ./dev/install-maven.sh

python3:
	bash ./dev/install-python.sh

golang:
	bash ./dev/install-golang.sh

nodejs:
	bash ./dev/install-nodejs.sh

rust:
	bash ./dev/install-rust.sh

gcc:
	bash ./dev/install-gcc.sh

glibc:
	bash ./dev/install-glibc.sh

cmake:
	bash ./dev/install-cmake.sh