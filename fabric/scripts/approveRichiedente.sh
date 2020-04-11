export FABRIC_CFG_PATH=/fabric/config

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=/fabric/organizations/ordererOrganizations/bacheca.com/orderers/orderer.bacheca.com/msp/tlscacerts/tlsca.bacheca.com-cert.pem
export BIGMARKET_RICHIEDENTE_CA=/fabric/organizations/peerOrganizations/richiedente.bacheca.com/peers/bigmarket-richiedente-bacheca-com/tls/ca.crt
export TECH_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/tech-forn1-bacheca-com/tls/ca.crt
export GARDEN_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/garden-forn1-bacheca-com/tls/ca.crt
export TECH_FORN2_CA=/fabric/organizations/peerOrganizations/forn2.bacheca.com/peers/tech-forn2-bacheca-com/tls/ca.crt

export ORDERER_URL=orderer-bacheca-com:7050
export CORE_PEER_LOCALMSPID="RichiedenteMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$BIGMARKET_RICHIEDENTE_CA
export CORE_PEER_MSPCONFIGPATH=/fabric/organizations/peerOrganizations/richiedente.bacheca.com/users/Admin@richiedente.bacheca.com/msp
export CORE_PEER_ADDRESS=bigmarket-richiedente-bacheca-com:7051


export CC_PACKAGE_ID_R=richiesta:200b6b42d71d6e24e2029b2477ee1dacf38402e7fc9185c4d1fa858d29b144ad
export CC_PACKAGE_ID_O=offerta:444f2e109f37d2d9b3f8da7cd5bd43b6a5ad20939cd6c1e95eca9096e5d08751

peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID techchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configT.json --package-id $CC_PACKAGE_ID_O --sequence 1 --tls true --cafile $ORDERER_CA
#peer lifecycle chaincode approveformyorg -o $ORDERER_URL --ordererTLSHostnameOverride orderer.bacheca.com --channelID gardenchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configG.json --package-id $CC_PACKAGE_ID_O --sequence 1 --tls true --cafile $ORDERER_CA
