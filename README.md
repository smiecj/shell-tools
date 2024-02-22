# shell tools
some shell for install and manage components conveniently

most shell come from [docker-centos](https://github.com/smiecj/docker-centos)

[中文](https://github.com/smiecj/shell-tools/blob/main/README_zh.md)

## gcc, glibc, cmake & make

```
# gcc
make gcc

# glibc
make glibc

# cmake
make cmake

# make
make make
```

## zsh

install zsh

```
make zsh
```

## python

install conda & python3

```
make python3
```

only install conda

```
make conda
```

## nodejs

install nodejs

```
make nodejs
```

## java

install java (1.8 & 17), maven and gradle

```
make java
```

install java 17

```
make java-new
```

install maven

```
make maven
```

## golang

install golang

```
make golang
```

## php

install php

```
make php
```

## rust

install rust

```
make rust
```

## [code server](https://github.com/coder/code-server)

```shell
make code-server
```

## [prometheus](https://github.com/prometheus/prometheus)

```shell
# will install prometheus, alertmanager, pushgateway and node-exporter
make prometheus
```

## [jupyter](https://github.com/jupyterhub/jupyterhub)

```shell
# will install jupyterhub + jupyterlab
make jupyter
```

## lvim

install neovim & lvim & cargo

```
make lvim
```