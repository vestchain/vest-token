#!/bin/bash

PREFIX="docker-compose exec nodvestd clvest"
if [ -z $1 ] ; then
  while :
  do
    read -e -p "clvest " cmd
    history -s "$cmd"
    $PREFIX $cmd
  done
else
  $PREFIX "$@"
fi
