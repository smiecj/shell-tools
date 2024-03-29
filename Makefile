ROOT = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
include $(ROOT)/Makefile.vars.repo
include $(ROOT)/Makefile.vars.version
include $(ROOT)/Makefile.vars.system
include $(ROOT)/Makefile.vars.service
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

conda:
	bash ./dev/install-conda.sh

python3:
	bash ./dev/install-python.sh

golang:
	bash ./dev/install-golang.sh

nodejs:
	bash ./dev/install-nodejs.sh

rust:
	bash ./dev/install-rust.sh

php:
	bash ./dev/install-php.sh

gcc:
	bash ./dev/install-gcc.sh

glibc:
	bash ./dev/install-glibc.sh

cmake:
	bash ./dev/install-cmake.sh

make:
	bash ./dev/install-make.sh

code-server:
	bash ./backend/code-server/install-code-server.sh

jupyter:
	bash ./backend/jupyter/install-jupyter.sh

prometheus:
	bash ./backend/prometheus/install-prometheus.sh

grafana:
	bash ./backend/grafana/install-grafana.sh

ffmpeg:
	bash ./life/media/install-ffmpeg.sh

opencc:
	bash ./life/media/install-opencc.sh

mediainfo:
	bash ./life/media/install-mediainfo.sh

metaflac:
	bash ./life/media/install-metaflac.sh