export FABRIC_CFG_PATH=/fabric/config

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=/fabric/organizations/ordererOrganizations/bacheca.com/orderers/orderer-bacheca-com/msp/tlscacerts/tlsca.bacheca.com-cert.pem
export BIGMARKET_RICHIEDENTE_CA=/fabric/organizations/peerOrganizations/richiedente.bacheca.com/peers/bigmarket-richiedente-bacheca-com/tls/ca.crt
export TECH_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/tech-forn1-bacheca-com/tls/ca.crt
export GARDEN_FORN1_CA=/fabric/organizations/peerOrganizations/forn1.bacheca.com/peers/garden-forn1-bacheca-com/tls/ca.crt
export TECH_FORN2_CA=/fabric/organizations/peerOrganizations/forn2.bacheca.com/peers/tech-forn2-bacheca-com/tls/ca.crt

export ORDERER_URL=orderer-bacheca-com:7050
export CORE_PEER_LOCALMSPID="RichiedenteMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$BIGMARKET_RICHIEDENTE_CA
export CORE_PEER_MSPCONFIGPATH=/fabric/organizations/peerOrganizations/richiedente.bacheca.com/users/Admin@richiedente.bacheca.com/msp
export CORE_PEER_ADDRESS=bigmarket-richiedente-bacheca-com:7051

peer lifecycle chaincode commit -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com --channelID techchannel --name richiesta --version 1.0 --init-required --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:8051 --tlsRootCertFiles $TECH_FORN1_CA --peerAddresses localhost:10051 --tlsRootCertFiles $TECH_FORN2_CA
peer chaincode invoke -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com  --tls true --cafile $ORDERER_CA -C techchannel -n richiesta --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:8051 --tlsRootCertFiles $TECH_FORN1_CA --peerAddresses localhost:10051 --tlsRootCertFiles $TECH_FORN2_CA --isInit -c '{"function":"init","Args":[]}'
peer lifecycle chaincode commit -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com --channelID techchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configT.json --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:8051 --tlsRootCertFiles $TECH_FORN1_CA --peerAddresses localhost:10051 --tlsRootCertFiles $TECH_FORN2_CA

peer lifecycle chaincode commit -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com --channelID gardenchannel --name richiesta --version 1.0 --init-required --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:9051 --tlsRootCertFiles $GARDEN_FORN1_CA
peer chaincode invoke -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com  --tls true --cafile $ORDERER_CA -C gardenchannel -n richiesta --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:9051 --tlsRootCertFiles $GARDEN_FORN1_CA --isInit -c '{"function":"init","Args":[]}'
peer lifecycle chaincode commit -o $ORDERER_URL --ordererTLSHostnameOverride orderer-bacheca-com --channelID gardenchannel --name offerta --version 1.0 --collections-config /fabric/chaincode/bacheca/offerta/collections_configG.json --sequence 1 --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $BIGMARKET_RICHIEDENTE_CA --peerAddresses localhost:9051 --tlsRootCertFiles $GARDEN_FORN1_CA
