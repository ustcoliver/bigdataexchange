package main

import (
	"log"

	"/home/debian/bigdataexchange/chaincode/data-exchange/chaincode/smartcontract.go"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// 初始化新合约
func main() {
	dataExchangeChaincode, err := contractapi.NewChaincode(&chaincode.SmartContract{})
	if err != nil {
		log.Panicf("Error creating data-exchange chaincode: %v", err)
	}

	if err := dataExchangeChaincode.Start(); err != nil {
		log.Panicf("Error starting data-exchange chaincode: %v", err)
	}
}
