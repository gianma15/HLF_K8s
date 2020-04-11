export FABRIC_CFG_PATH=/fabric/config

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=/fabric/organizations/ordererOrganizations/bacheca.com/orderers/orderer-bacheca-com/msp/tlscacerts/tlsca.bacheca.com-cert.pem
export BIGMARKET_RICHIEDENTE_CA=/fabric/organizations/peerOrganizations/richiedente.bacheca.com/peers/bigmarket-richiedente-bacheca-com/tls/ca.crt
export TECH_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/tech-forn1-bacheca-com/tls/ca.crt
export TECH_FORN2_CA=/fabric/organizations/peerOrganizations/forn2.bacheca.com/peers/tech-forn2-bacheca-com/tls/ca.crt

export ORDERER_URL=orderer-bacheca-com:7050
export CORE_PEER_LOCALMSPID="Forn2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$TECH_FORN2_CA
export CORE_PEER_MSPCONFIGPATH=/fabric/organizations/peerOrganizations/forn2.bacheca.com/users/Admin@forn2.bacheca.com/msp
export CORE_PEER_ADDRESS=tech-forn2-bacheca-com:10051

peer lifecycle chaincode install offerta.tar.gz
peer lifecycle chaincode install richiesta.tar.gz
peer lifecycle chaincode queryinstalled

export CC_PACKAGE_ID_R=$1
export CC_PACKAGE_ID_O=$2

peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com --channelID techchannel --name richiesta --version 1.0 --init-required --package-id $CC_PACKAGE_ID_R --sequence 1 --tls true --cafile $ORDERER_CA
peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com --channelID techchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configT.json --package-id $CC_PACKAGE_ID_O --sequence 1 --tls true --cafile $ORDERER_CA
