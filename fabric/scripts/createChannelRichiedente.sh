export FABRIC_CFG_PATH=/fabric/config

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=/fabric/organizations/ordererOrganizations/bacheca-com/orderers/orderer-bacheca-com/msp/tlscacerts/tlsca-bacheca-com-cert.pem
export BIGMARKET_RICHIEDENTE_CA=/fabric/organizations/peerOrganizations/richiedente-bacheca-com/peers/bigmarket-richiedente-bacheca-com/tls/ca.crt
export TECH_FORN1_CA=/fabric/organizations/peerOrganizations/forn1-bacheca-com/peers/tech.forn1-bacheca-com/tls/ca.crt
export GARDEN_FORN1_CA=/fabric/organizations/peerOrganizations/forn1-bacheca-com/peers/garden.forn1-bacheca-com/tls/ca.crt
export TECH_FORN2_CA=/fabric/organizations/peerOrganizations/forn2-bacheca-com/peers/tech.forn2-bacheca-com/tls/ca.crt

export ORDERER_URL=orderer-bacheca-com:7050
export CORE_PEER_LOCALMSPID="RichiedenteMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$BIGMARKET_RICHIEDENTE_CA
export CORE_PEER_MSPCONFIGPATH=/fabric/organizations/peerOrganizations/richiedente-bacheca-com/users/Admin@richiedente-bacheca-com/msp
export CORE_PEER_ADDRESS=bigmarket-richiedente-bacheca-com:7051

MAX_RETRY=5
DELAY=3

function createTechChannel(){
  set -x
  peer channel create -o $ORDERER_URL -c techchannel --ordererTLSHostnameOverride orderer-bacheca-com -f /fabric/channel-artifacts/TechChannel.tx --outputBlock /fabric/channel-artifacts/techchannel.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
  res=$?
  set +x

  cat log.txt
	verifyResult $res "Channel creation failed"
	echo
	echo "===================== Channel 'Tech Channel' created ===================== "
	echo
}

function createGardenChannel(){
  set -x
  peer channel create -o $ORDERER_URL -c gardenchannel --ordererTLSHostnameOverride orderer-bacheca-com -f /fabric/channel-artifacts/GardenChannel.tx --outputBlock /fabric/channel-artifacts/gardenchannel.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
  res=$?
  set +x

  cat log.txt
	verifyResult $res "Channel creation failed"
	echo
	echo "===================== Channel 'Garden Channel' created ===================== "
	echo
}

function createChannels() {
  createTechChannel
  createGardenChannel

}

function verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

function joinTechChannel(){
  	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b /fabric/channel-artifacts/techchannel.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	echo
	verifyResult $res "After $MAX_RETRY attempts, BigMarket Tech has failed to join channel 'TechChannel' "

  set -x
    peer channel update -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com -c techchannel -f /fabric/channel-artifacts/TechRichiedenteAnchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel 'TechChannel' ===================== "
  sleep $DELAY
  echo
}

function joinGardenChannel(){
  local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b /fabric/channel-artifacts/gardenchannel.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	echo
	verifyResult $res "After $MAX_RETRY attempts, BigMarket Tech has failed to join channel 'gardenchannel' "

  set -x
    peer channel update -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com -c gardenchannel -f /fabric/channel-artifacts/GardenRichiedenteAnchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel 'gardenchannel' ===================== "
  sleep $DELAY
  echo
}

function joinChannels() {
  joinTechChannel
  joinGardenChannel
}

createChannels
joinChannels