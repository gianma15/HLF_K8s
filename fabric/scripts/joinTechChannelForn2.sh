# export PATH=/fabric/../bin:/fabric:$PATH
# export FABRIC_CFG_PATH=/fabric/config
# export CORE_PEER_TLS_ENABLED=true

# export ORDERER_CA=/fabric/organizations/ordererOrganizations/bacheca.com/orderers/orderer.bacheca.com/msp/tlscacerts/tlsca.bacheca.com-cert.pem
# export BIGMARKET_RICHIEDENTE_CA=/fabric/organizations/peerOrganizations/richiedente.bacheca.com/peers/bigmarket-richiedente-bacheca-com/tls/ca.crt
# export TECH_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/tech-forn1-bacheca-com/tls/ca.crt
# export TECH_FORN2_CA=/fabric/organizations/peerOrganizations/forn2.bacheca.com/peers/tech-forn2-bacheca-com/tls/ca.crt

# export CORE_PEER_LOCALMSPID="Forn2MSP"
# export CORE_PEER_TLS_ROOTCERT_FILE=$TECH_FORN2_CA
# export CORE_PEER_MSPCONFIGPATH=/fabric/organizations/peerOrganizations/forn2.bacheca.com/users/Admin@forn2.bacheca.com/msp
# export CORE_PEER_ADDRESS=localhost:10051
MAX_RETRY=5
DELAY=3

function verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

function joinChannel() {
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b ./channel-artifacts/techchannel.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	echo
	verifyResult $res "After $MAX_RETRY attempts, Forn2 Tech has failed to join channel 'TechChannel' "

  set -x
    peer channel update -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com -c techchannel -f ./channel-artifacts/TechForn2Anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel 'TechChannel' ===================== "
  sleep $DELAY
  echo
}

joinChannel