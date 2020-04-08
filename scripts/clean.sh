rm -r organizations/peerOrganizations 
rm -r organizations/ordererOrganizations 
rm -r channel-artifacts
docker kill $(docker ps -a -q)
docker rm $(docker ps -a -q)
reset