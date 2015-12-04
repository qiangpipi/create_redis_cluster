#!/bin/bash
#Parse parameter
#Print help if command wrong
if [ ! $master ];then
  echo "command like: master=3 ./init.sh"
  echo "Script will create <master> master nodes"
  echo "and <master> slave nodes"
  exit 1
fi
if [ $master -lt 1 ];then
  echo "Script will create <master> master nodes"
  echo "and <master> slave nodes"
  exit 1
fi
if [ ! $nodebase ];then
  nodebase=`pwd`
fi
if [ ! -f $nodebase/redis.conf.tpl ];then
  echo "Base folder not existing"
  exit 1
fi
if [ -f $nodebase/nodelist ];then
  echo "Already nodes exist; please terminate them first"
  exit 1
fi
#Get node list
baseport=7000
slots=16384
allnum=$(( master*2 ))
#Create new node folder and configuration
for (( i=0; i<allnum; i++ ))
do
  port=$(( baseport+i ))
  echo $port >> $nodebase/nodelist
  mkdir -p $nodebase/$port
  cp $nodebase/redis.conf.tpl $nodebase/$port/redis.conf
  if [ -f $nodebase/$port/redis.conf ];then
    sed -i "s/port 7000/port $port/" $nodebase/$port/redis.conf
    cd $nodebase/$port
    redis-server redis.conf
  fi
done
for line in `cat $nodebase/nodelist`
do
  res=`redis-cli -p $line ping`
  if [ "PONG" = $res ];then
#Meet nodes
    echo "Node $line started"
    res=`redis-cli -p $baseport cluster meet 127.0.0.1 $line`
    if [ ! $res ];then
      echo "Node $line fail to meet"
    elif [ "OK" = $res ];then
      echo "Node $line met ok"
    fi
  else
    echo "Node $line fail to start"
  fi
done
###################################################################################
#Add slots for each master
###################################################################################
avn=$(( slots/master ))
j=0
i=0
sn=$avn
while [ $j -lt $slots ]
do
  if [ $(( i+1 )) -eq $master ];then
    sn=$(( avn+slots%avn ))
  fi
  mp=$(( baseport+i ))
  a=0
  while [ $a -lt $sn ]
  do
#Add slots for master nodes
    redis-cli -p $mp cluster addslots $j >> /dev/null
#    echo "redis-cli -p $mp cluster addslots $j"
    a=$(( a+1 ))
    j=$(( j+1 ))
  done
  i=$(( i+1 ))
done
###################################################################################
###################################################################################
#Set slave for each master
redis-cli -c -p $baseport cluster nodes > /tmp/nodetmp
for (( i=0;i<master;i++ ))
do
  mp=$(( baseport+i ))
  mid=`grep $mp /tmp/nodetmp|cut -d" " -f1`
  sp=$(( baseport+i+master ))
  res=`redis-cli -c -p $sp cluster replicate $mid`
  echo $res
  if [ ! $res ];then
    echo "Master $mp add slave $sp failed"
  elif [ "OK" = $res ];then
    echo "Master $mp added slave $sp OK"
  fi
done
rm /tmp/nodetmp
