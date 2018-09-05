#!/bin/bash

arg=$1
echo $1

shift

more $1 > $arg

echo $@

