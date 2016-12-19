#!/bin/bash
#Parse parameter
#Print help if command wrong
if [ ! $nodebase ];then
  nodebase=$(dirname $(pwd)/${0})
fi
if [ ! -f $nodebase/redis.conf.tpl ];then
  echo "Base folder not existing"
  exit 1
fi
#Get node list
if [ -f $nodebase/nodelist ];then
  for line in `cat $nodebase/nodelist`
  do
#Check node status live/dead
    res=`redis-cli -p $line ping`
#Stop node
    if [ ! $res ];then
      echo "Node $line already shutdown"
    elif [ "PONG" = $res ];then
      redis-cli -p $line shutdown
      echo "Node $line shutdown"
    fi
#Revemo node folder
  rm -rf $nodebase/$line
  done
  rm $nodebase/nodelist
fi
echo "All nodes terminated"
