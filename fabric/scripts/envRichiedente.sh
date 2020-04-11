#export PATH=/fabric/../bin:fabric:$PATH
export FABRIC_CFG_PATH=/fabric/config

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=/fabric/organizations/ordererOrganizations/bacheca.com/orderers/orderer-bacheca-com/msp/tlscacerts/tlsca.bacheca.com-cert.pem
export BIGMARKET_RICHIEDENTE_CA=/fabric/organizations/peerOrganizations/richiedente.bacheca.com/peers/bigmarket-richiedente-bacheca-com/tls/ca.crt
export TECH_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/tech-forn1-bacheca-com/tls/ca.crt
export GARDEN_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/garden-forn1-bacheca-com/tls/ca.crt
export TECH_FORN2_CA=/fabric/organizations/peerOrganizations/forn2.bacheca.com/peers/tech-forn2-bacheca-com/tls/ca.crt

export CORE_PEER_LOCALMSPID="RichiedenteMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$BIGMARKET_RICHIEDENTE_CA
export CORE_PEER_MSPCONFIGPATH=/fabric/organizations/peerOrganizations/richiedente.bacheca.com/users/Admin@richiedente.bacheca.com/msp
export CORE_PEER_ADDRESS=bigmarket.richiedente.bacheca.com:7051