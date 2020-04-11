#export PATH=/fabric/./fabric/bin:/fabric:$PATH
export FABRIC_CFG_PATH=/fabric/config
#export VERBOSE=false
# use this as the default docker-compose yaml definition
COMPOSE_FILE_BASE=docker/docker-compose-bacheca-net.yaml
# docker-compose.yaml file if you are using couchdb
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml
# certificate authorities compose file
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml
#language
CC_RUNTIME_LANGUAGE=javascript
# Chaincode version
VERSION=1
# default image tag
IMAGETAG="2.0.0"
# default database
DATABASE="couchdb"
DELAY="3"
export CORE_PEER_TLS_ENABLED=true
export ORDERER_URL=orderer-bacheca-com:7050
export ORDERER_CA=/fabric/organizations/ordererOrganizations/bacheca.com/orderers/orderer.bacheca.com/msp/tlscacerts/tlsca.bacheca.com-cert.pem
export TECH_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/tech-forn1-bacheca-com/tls/ca.crt
export GARDEN1_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/garden-forn1-bacheca-com/tls/ca.crt
export TECH_FORN2_CA=/fabric/organizations/peerOrganizations/forn2.bacheca.com/peers/tech-forn2-bacheca-com/tls/ca.crt

function createOrgs(){
    #if [ -d "organizations/peerOrganizations" || -d "organizations/ordererOrganizations"]; then
    rm -r /fabric/organizations/peerOrganizations && rm -r /fabric/organizations/ordererOrganizations && rm -r /fabric/channel-artifacts
    #fi

    which cryptogen
    if [ "$?" -ne 0 ]; then
        echo "cryptogen tool not found. exiting"
        exit 1
    fi
    echo
    echo "##########################################################"
    echo "##### Generate certificates using cryptogen tool #########"
    echo "##########################################################"
    echo

    echo "##########################################################"
    echo "############ Create Richiedente Identities ######################"
    echo "##########################################################"

    set -x
    cryptogen generate --config=/fabric/organizations/cryptogen/crypto-config-richiedente.yaml --output="organizations"
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate certificates..."
        exit 1
    fi


    echo "##########################################################"
    echo "############ Create Forn1 Identities ######################"
    echo "##########################################################"

    set -x
    cryptogen generate --config=/fabric/organizations/cryptogen/crypto-config-forn1.yaml --output="organizations"
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate certificates..."
        exit 1
    fi

    echo "##########################################################"
    echo "############ Create Forn2 Identities ######################"
    echo "##########################################################"

    set -x
    cryptogen generate --config=/fabric/organizations/cryptogen/crypto-config-forn2.yaml --output="organizations"
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate certificates..."
        exit 1
    fi


    echo "##########################################################"
    echo "############ Create Orderer Identities ######################"
    echo "##########################################################"

    set -x
    cryptogen generate --config=/fabric/organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate certificates..."
        exit 1
    fi
}

function createOrdererGenesis() {

  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  echo "#########  Generating Orderer Genesis block ##############"

  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  set -x
  configtxgen -profile ThreeOrgsOrdererGenesis -channelID system-channel -outputBlock /fabric/system-genesis-block/genesis.block
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
}

function createChannelsArtifacts() {
  
    if [ ! -d "/fabric/channel-artifacts" ]; then
    mkdir channel-artifacts
    fi

    echo
    echo "##########################################################"
    echo "######## Generate GardenChannel artifacts ################"
    echo "##########################################################"
    echo
    set -x
    configtxgen -profile GardenChannel -outputCreateChannelTx /fabric/channel-artifacts/GardenChannel.tx -channelID gardenchannel
    res=$?
    set +x

    if [ $res -ne 0 ]; then
        echo "Failed to generate channel configuration transaction..."
        exit 1
    fi

    echo
    echo "##########################################################"
    echo "######## Generate TechChannel artifacts ##################"
    echo "##########################################################"
    echo
    set -x
    configtxgen -profile TechChannel -outputCreateChannelTx /fabric/channel-artifacts/TechChannel.tx -channelID techchannel
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate channel configuration transaction..."
        exit 1
    fi
    echo

    # now run the script that creates a channel. This script uses configtxgen once
    # more to create the channel creation transaction and the anchor peer updates.
    # configtx.yaml is mounted in the cli container, which allows us to use it to
    # create the channel artifacts
    #scripts/createChannel.sh $CHANNEL_NAME $CLI_DELAY $MAX_RETRY $VERBOSE
    if [ $? -ne 0 ]; then
    echo "Error !!! Create channel failed"
    exit 1
    fi
    echo
    echo "######## CHANNEL ARTIFACTS GENERATED ##################"
    echo

}

function verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

function createAnchorArtifacts(){
    echo
    echo "##########################################################"
    echo "######## Generate Richiedente Anchor artifacts ##################"
    echo "##########################################################"
    echo
    set -x
    configtxgen -profile TechChannel -outputAnchorPeersUpdate /fabric/channel-artifacts/TechRichiedenteAnchors.tx -channelID techchannel -asOrg RichiedenteMSP
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate channel configuration transaction..."
        exit 1
    fi
    echo
    set -x
    configtxgen -profile GardenChannel -outputAnchorPeersUpdate /fabric/channel-artifacts/GardenRichiedenteAnchors.tx -channelID gardenchannel -asOrg RichiedenteMSP
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate channel configuration transaction..."
        exit 1
    fi
    echo
    echo "##########################################################"
    echo "######## Generate Forn1 Anchor artifacts ##################"
    echo "##########################################################"
    echo
    set -x
    configtxgen -profile GardenChannel -outputAnchorPeersUpdate /fabric/channel-artifacts/GardenForn1Anchors.tx -channelID gardenchannel -asOrg Forn1MSP
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate channel configuration transaction..."
        exit 1
    fi
    echo
    set -x
    configtxgen -profile TechChannel -outputAnchorPeersUpdate /fabric/channel-artifacts/TechForn1Anchors.tx -channelID techchannel -asOrg Forn1MSP
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate channel configuration transaction..."
        exit 1
    fi
    echo
    echo "##########################################################"
    echo "######## Generate Forn2 artifacts ##################"
    echo "##########################################################"
    echo
    set -x
    configtxgen -profile TechChannel -outputAnchorPeersUpdate /fabric/channel-artifacts/TechForn2Anchors.tx -channelID techchannel -asOrg Forn2MSP
    res=$?
    set +x

    if [ $res -ne 0 ]; then
        echo "Failed to generate anchor configuration transaction..."
        exit 1
    fi
    echo

    if [ $? -ne 0 ]; then
    echo "Error !!! Create anchor failed"
    exit 1
    fi

}

function packageInstall(){

  source /fabric/scripts/envRichiedente.sh
  /fabric/scripts/createChannelRichiedente.sh
  echo  "--------------------------------------------------PACKAGE INSTALL-------------------------------------------------------"
  peer lifecycle chaincode package offerta.tar.gz --path /fabric/chaincode/bacheca/offerta --lang node --label offerta 
  peer lifecycle chaincode install offerta.tar.gz
  export CC_PACKAGE_ID_O=$( peer lifecycle chaincode queryinstalled | grep -Go "offerta:\w*")
  echo $CC_PACKAGE_ID_O
  peer lifecycle chaincode package richiesta.tar.gz --path /fabric/chaincode/bacheca/richiesta --lang node --label richiesta 
  peer lifecycle chaincode install richiesta.tar.gz
  export CC_PACKAGE_ID_R=$( peer lifecycle chaincode queryinstalled | grep -Go "richiesta:\w*")
  echo $CC_PACKAGE_ID_R

  source /fabric/scripts/envTechForn1.sh
  /fabric/scripts/joinTechChannelForn1.sh
  peer lifecycle chaincode install offerta.tar.gz
  peer lifecycle chaincode install richiesta.tar.gz

  source /fabric/scripts/envTechForn2.sh
  /fabric/scripts/joinTechChannelForn2.sh 
  peer lifecycle chaincode install offerta.tar.gz
  peer lifecycle chaincode install richiesta.tar.gz

  source /fabric/scripts/envGardenForn1.sh
  /fabric/scripts/joinGardenChannelForn1.sh 
  peer lifecycle chaincode install offerta.tar.gz 
  peer lifecycle chaincode install richiesta.tar.gz

}

function approve(){
  echo  "--------------------------------------------------APPROVE RICHIEDENTE-------------------------------------------------------"
  source /fabric/scripts/envRichiedente.sh
  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID techchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configT.json --package-id $CC_PACKAGE_ID_O --sequence 1 --tls true --cafile $ORDERER_CA
  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID gardenchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configG.json --package-id $CC_PACKAGE_ID_O --sequence 1 --tls true --cafile $ORDERER_CA

  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID techchannel --name richiesta --version 1.0 --init-required --package-id $CC_PACKAGE_ID_R --sequence 1 --tls true --cafile $ORDERER_CA
  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID gardenchannel --name richiesta --version 1.0 --init-required  --package-id $CC_PACKAGE_ID_R --sequence 1 --tls true --cafile $ORDERER_CA

  echo  "--------------------------------------------------APPROVE TECH1-------------------------------------------------------"
  source /fabric/scripts/envTechForn1.sh
  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID techchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configT.json --package-id $CC_PACKAGE_ID_O --sequence 1 --tls true --cafile $ORDERER_CA
  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID techchannel --name richiesta --version 1.0 --init-required --package-id $CC_PACKAGE_ID_R --sequence 1 --tls true --cafile $ORDERER_CA

  echo  "--------------------------------------------------APPROVE TECH2-------------------------------------------------------"
  source /fabric/scripts/envTechForn2.sh
  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID techchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configT.json --package-id $CC_PACKAGE_ID_O --sequence 1 --tls true --cafile $ORDERER_CA
  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID techchannel --name richiesta --version 1.0 --init-required --package-id $CC_PACKAGE_ID_R --sequence 1 --tls true --cafile $ORDERER_CA

  echo  "--------------------------------------------------APPROVE GARDEN1-------------------------------------------------------"
  source /fabric/scripts/envGardenForn1.sh
  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID gardenchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configG.json --package-id $CC_PACKAGE_ID_O --sequence 1 --tls true --cafile $ORDERER_CA
  peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID gardenchannel --name richiesta --version 1.0 --init-required --package-id $CC_PACKAGE_ID_R --sequence 1 --tls true --cafile $ORDERER_CA

}

function commit(){
  echo  "--------------------------------------------------COMMIT-------------------------------------------------------"
  source /fabric/scripts/envRichiedente.sh
  peer lifecycle chaincode commit -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID techchannel --name richiesta --version 1.0 --init-required --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:8051 --tlsRootCertFiles $TECH_FORN1_CA --peerAddresses localhost:10051 --tlsRootCertFiles $TECH_FORN2_CA
  peer chaincode invoke -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com  --tls true --cafile $ORDERER_CA -C techchannel -n richiesta --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:8051 --tlsRootCertFiles $TECH_FORN1_CA --peerAddresses localhost:10051 --tlsRootCertFiles $TECH_FORN2_CA --isInit -c '{"function":"init","Args":[]}'
  peer lifecycle chaincode commit -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID techchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configT.json --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:8051 --tlsRootCertFiles $TECH_FORN1_CA --peerAddresses localhost:10051 --tlsRootCertFiles $TECH_FORN2_CA

  peer lifecycle chaincode commit -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID gardenchannel --name richiesta --version 1.0 --init-required --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:9051 --tlsRootCertFiles $GARDEN_FORN1_CA
  peer chaincode invoke -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com  --tls true --cafile $ORDERER_CA -C gardenchannel -n richiesta --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:9051 --tlsRootCertFiles $GARDEN_FORN1_CA --isInit -c '{"function":"init","Args":[]}'
  peer lifecycle chaincode commit -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID gardenchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configG.json --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:9051 --tlsRootCertFiles $GARDEN_FORN1_CA
}

function networkUp() {
    createOrgs
    createOrdererGenesis
    createChannelsArtifacts
    createAnchorArtifacts
    # packageInstall
    # approve
    # commit
}

networkUp
