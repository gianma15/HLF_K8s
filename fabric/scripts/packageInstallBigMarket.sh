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

echo  "--------------------------------------------------PACKAGE INSTALL-------------------------------------------------------"
peer lifecycle chaincode package offerta.tar.gz --path /fabric/chaincode/bacheca/offerta --lang node --label offerta 
peer lifecycle chaincode install offerta.tar.gz
#export CC_PACKAGE_ID_O=$( peer lifecycle chaincode queryinstalled | grep -Go "offerta:\w*")
peer lifecycle chaincode package richiesta.tar.gz --path /fabric/chaincode/bacheca/richiesta --lang node --label richiesta 
peer lifecycle chaincode install richiesta.tar.gz
#export CC_PACKAGE_ID_R=$( peer lifecycle chaincode queryinstalled | grep -Go "richiesta:\w*")
echo "||||||||||                          ||||||||||"
echo "|||||||||| PACKAGE ID dei Chaincode ||||||||||"
echo "vvvvvvvvvv                          vvvvvvvvvv"
peer lifecycle chaincode queryinstalled
#echo $CC_PACKAGE_ID_O
#echo $CC_PACKAGE_ID_R