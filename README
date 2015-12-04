###Precondition:###
This script created base on eht redis server 3.0.5.
Go to [redis.io](http://redis.io/download) download a stable version
Install the redis:
  wget http://download.redis.io/releases/redis-<x.x.x>.tar.gz
  tar xzf redis-<x.x.x>.tar.gz
  cd redis-<x.x.x>
  make
  sudo make install

###Installation:###
  git clone https://github.com/qiangpipi/create_redis_cluster.git
And no more.

###Usage:###
File init.sh
  cd <git_clone_folder>
  master=<num> ./init.sh
$master is the number of master which you want to create.
This script will create nodes locally.
Node port will start from 7000.
This script will add slots for each master node automatically.
This script will create and add 1 slave for each master node.

File terminate.sh
  cd <git_clone_folder>
  ./terminate.sh
No parameter needed.
This script will shutdown all nodes.
This script will destroy all configuration and data file of nodes.

File redis.conf.tpl
This is the template of the configuration file.
init.sh will create nodes base on this configuration.
