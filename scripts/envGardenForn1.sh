export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/config
export CORE_PEER_TLS_ENABLED=true

export ORDERER_CA=${PWD}/organizations/ordererOrganizations/bacheca.com/orderers/orderer.bacheca.com/msp/tlscacerts/tlsca.bacheca.com-cert.pem
export BIGMARKET_RICHIEDENTE_CA=${PWD}/organizations/peerOrganizations/richiedente.bacheca.com/peers/bigMarket.richiedente.bacheca.com/tls/ca.crt
export GARDEN_FORN1_CA=${PWD}/organizations/peerOrganizations/forn1.bacheca.com/peers/garden.forn1.bacheca.com/tls/ca.crt

export CORE_PEER_LOCALMSPID="Forn1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$GARDEN_FORN1_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/forn1.bacheca.com/users/Admin@forn1.bacheca.com/msp
export CORE_PEER_ADDRESS=localhost:9051