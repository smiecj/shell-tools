ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
include $(ROOT)/Makefile.vars
export

hello:
	@echo "hello shell tools!"

python3:
	bash ./dev/install-python.sh