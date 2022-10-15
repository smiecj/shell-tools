ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
include $(ROOT)/Makefile.vars.repo
include $(ROOT)/Makefile.vars.version
export

hello:
	@echo "hello shell tools!"

python3:
	bash ./dev/install-python.sh

nodejs:
	bash ./dev/install-nodejs.sh