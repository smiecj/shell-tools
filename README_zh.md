# shell tools
脚本工具，用于更方便地安装基础环境、基础组件等

大部分脚本逻辑来自 [docker-centos](https://github.com/smiecj/docker-centos)

## gcc, glibc, cmake 和 make

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

安装 zsh

```
make zsh
```

## python

安装 conda & python3

```
make python3
```

只安装 conda

```
make conda
```

## nodejs

安装 nodejs

```
make nodejs
```

## java

安装 java (1.8 & 17)

```
make java
```

安装 java 17

```
make java-new
```

安装 maven

```
make maven
```

## golang

安装 golang

```
make golang
```

## php

安装 php

```
make php
```

## rust

安装 rust

```
make rust
```

## [code server](https://github.com/coder/code-server)

```shell
make code-server
```

## [prometheus](https://github.com/prometheus/prometheus)

```shell
# 安装 prometheus, alertmanager, pushgateway 和 node-exporter
make prometheus
```

## [jupyter](https://github.com/jupyterhub/jupyterhub)

```shell
# 安装 jupyterhub 和 jupyterlab
make jupyter
```

## lvim

安装 neovim 、 lvim 、 cargo

```
make lvim
```

## media

安装媒体相关工具

```
# 安装 ffmpeg
make ffmpeg

# 安装 opencc
make opencc

# 安装 mediainfo
make mediainfo

# 安装 metaflac
make metaflac
```