## Base Image
FROM ubuntu:16.04

## Environment Variables
# ENV TMP_FOLDER=$(mktemp -d)
ENV CONFIG_FILE='aced.conf'
ENV CONFIGFOLDER='/root/.acedcore'
ENV COIN_DAEMON='/usr/local/bin/acedd'
ENV COIN_CLI='/usr/local/bin/aced-cli'
ENV COIN_REPO='https://github.com/Acedcoin/AceD/releases/download/1.8/v18_bugfix.tar.gz'
ENV COIN_NAME='AceD'
ENV COIN_PORT=24126
ENV CONFIG_FILE='aced.conf'
ENV CONFIGFOLDER='/root/.acedcore'
#ENV COIN_BS='http://149.28.231.161/bootstrap.zip'
ENV COINKEY=""

# ENV NODEIP=$(curl -s4 icanhazip.com)
ENV RED='\033[0;31m'
ENV GREEN='\033[0;32m'
ENV NC='\033[0m'

## Install Dependencies
RUN apt-get upgrade && apt-get update && apt-get install -y \
    software-properties-common
RUN apt-add-repository -y ppa:bitcoin/bitcoin
RUN apt-get update && apt-get install -y \
    build-essential libtool autoconf libssl-dev libboost-dev sudo automake \
    make wget curl unzip ufw git pkg-config net-tools \ 
    libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
    libboost-system-dev libboost-test-dev libboost-thread-dev \
    libdb4.8-dev bsdmainutils libdb4.8++-dev libminiupnpc-dev \
    libgmp3-dev libzmq3-dev libevent-dev libdb5.3++

## Download Binaries and copy to system folder
WORKDIR /root
RUN wget -nv -O - $COIN_REPO | tar xvz -C /root
RUN cp /root/v18_bugfix/* /usr/local/bin \
    && strip /usr/local/bin/acedd /usr/local/bin/aced-cli \
    && chmod +x /usr/local/bin/acedd && chmod +x /usr/local/bin/aced-cli \
    && rm -rf /root/v18_bugfix

WORKDIR /root
COPY ./aced_install.sh ./
RUN chmod +x /root/aced_install.sh
CMD [ "aced_install.sh" ]
ENTRYPOINT [ "bash" ]
