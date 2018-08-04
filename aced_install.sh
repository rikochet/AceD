#!/bin/bash

TMP_FOLDER=$(mktemp -d)
NODEIP=$(curl -s4 icanhazip.com)

function create_config() {
  echo -e "Creating Config..."
  mkdir $CONFIGFOLDER
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
port=$COIN_PORT
EOF
}

function update_config() {
  echo -e "Updating Config..."
  sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
logintimestamps=1
maxconnections=256
#bind=$NODEIP
masternode=1
externalip=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY
EOF
}

function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
    echo "IP Address.. $NODEIP"
  fi
}

function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}

function important_information() {
 echo
 echo -e "================================================================================================================================"
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
 if [[ -n $SENTINEL_REPO  ]]; then
  echo -e "${RED}Sentinel${NC} is installed in ${RED}/sentinel${NC}"
  echo -e "Sentinel logs is: ${RED}$CONFIGFOLDER/sentinel.log${NC}"
 fi
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "================================================================================================================================"
}

function import_bootstrap() {
  if [ ! -d "$CONFIGFOLDER/blocks" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
    echo -e "Downloading Bootstrap..."
    wget -q $COIN_BS
    compile_error
    echo -e "Importing Bootstrap..."
    COIN_ZIP=$(echo $COIN_BS | awk -F'/' '{print $NF}')
    unzip $COIN_ZIP
    compile_error
    cp -r ~/bootstrap/blocks ~/.acedcore/blocks
    cp -r ~/bootstrap/chainstate ~/.acedcore/chainstate
    cp -r ~/bootstrap/peers.dat ~/.acedcore/peers.dat
    rm -r ~/bootstrap/
    rm $COIN_ZIP
    echo -e "Import Complete!"
  fi
}

function setup_node() {
  echo -e "Setting up..."
  get_ip
  create_config
  #import_bootstrap
  update_config
}

function run_node() {
  echo -e "Running node..."
  acedd -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
  tail -f /root/.acedcore/debug.log
}

##### Main #####
setup_node
run_node
