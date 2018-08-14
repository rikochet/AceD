# AceD - docker image
This docker image includes shell script to install a [AceD Masternode](http://www.acedcoin.com/) on a Linux server running Ubuntu 16.04.  
  
This script will install **AceD v1.7**.
***


#__If you haven't already setup your desktop wallet then follow the instuctions [here](https://github.com/rikochet/AceD-Docker/blob/master/README-Desktop.md) to get ready!__


## Server Pre-requisites:
Download and install docker.

```
$ apt-get install docker.io
```

## Download & build image:
Grab a copy of the AceD-Docker image template from github and build the template as local image.

```
$ git clone https://github.com/rikochet/AceD-Docker.git \
&& cd AceD-Docker \
&& docker build -t aced-masternode .
```

## Configure and run image
Use docker to create a new volume (aced-mn1) and run the new image.

- COINKEY is your Master Node Private Key - *[see Desktop Wallet instructions](https://github.com/rikochet/AceD-Docker/blob/master/README-Desktop.md)*
- COIN_PORT (default: 24126) is the port used to communicate with the AceD network

```
$ docker volume create aced-mn1
$ docker run -dit --restart unless-stopped \
--name Aced-MN1 \
-v aced-mn1:/root/.acedcore \
-p 24126:24126 \
-e COIN_PORT=24126 \
-e COINKEY='ABCDEFGHIJKLMNOPQRTSUVWXYZ0123456789' \
aced-masternode:latest

```


## Usage:
Connect to the container with exec

```
$ docker exec -it Aced-MN1 bash
```

Some helpful commands for checking up on your master node..

```
$ aced-cli getinfo
$ aced-cli masternode status
$ aced-cli mnsync status
```

***

## Donations:  

Any donation is highly appreciated.  

**AceD**: ATeSNRSwwPnXAoJgoviC4TAhQrXLVh8nnC  
**BTC**: 1J8SDZmePwqf7yw1ccDoywJctvg5qZPBVK  
**ETH**: 0x61a648673b8364CBa3DB5bd91b3bC6B5c7144e87  
**Bcash**: qr8dxswrpqlyz9pwyxh92n6j5djm6g44jq9d6th8jm
