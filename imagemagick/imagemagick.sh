#!/usr/bin/env bash

#命令行修改工程目录下所有 png 资源 hash 值
#使用 ImageMagick 进行图片压缩，所以需要安装 ImageMagick，安装方法 brew install imagemagick
find . -iname "*.png" -exec echo {} \; -exec convert {} {} \;
#or
#find . -iname "*.png" -exec echo {} \; -exec convert {} -quality 95 {} \;
