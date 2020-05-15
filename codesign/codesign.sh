#!/usr/bin/env bash

# 重签名
codesign --force --deep --sign - $1