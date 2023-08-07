package chaincode

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing an Asset
type SmartContract struct {
	contractapi.Contract
}

// 数据子集结构体，包含数据子集名称、描述、hash、创建时间、更新时间、数据集价格
type DataSubset struct {
	Name        string   `json:"name"`
	Description string   `json:"description"`
	Hash        []string `json:"hash"`
	CreateTime  string   `json:"createTime"`
	UpdateTime  string   `json:"updateTime"`
	Price       int      `json:"price"`
}

// 数据集结构体，包含数据子集的数组、数据集名称、描述、hash、创建时间、更新时间
type DataSet struct {
	DataSubset  []DataSubset `json:"dataSubset"`
	Name        string       `json:"name"`
	Description string       `json:"description"`
	Hash        []string     `json:"hash"`
	CreateTime  string       `json:"createTime"`
	UpdateTime  string       `json:"updateTime"`
}

// 数据集名称数组
var dataSetName []string

// 合约创建者ID
var creatorID string

// 初始化账本函数，记录合约创建者id
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	creatorID, _ = ctx.GetClientIdentity().GetID()
	return nil
}

// 查询数据集是否存在
func (s *SmartContract) DataSetExists(ctx contractapi.TransactionContextInterface, name string) (bool, error) {
	// 获取数据集
	dataSetJSON, err := ctx.GetStub().GetState(name)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}

	// 如果数据集不存在，返回false
	if dataSetJSON == nil {
		return false, nil
	}

	return true, nil
}

// 创建数据集函数，传入数据集名称、描述、hash、创建时间、更新时间，创建数据集
func (s *SmartContract) CreateDataSet(ctx contractapi.TransactionContextInterface, name string, description string, hash []string, createTime string, updateTime string) error {
	//检查合约调用者是否为合约创建者
	currentID, _ := ctx.GetClientIdentity().GetID()
	if currentID != creatorID {
		return fmt.Errorf("the creator of the dataset is not the creator of the contract")
	}
	// 检查数据集是否存在
	exists, err := s.DataSetExists(ctx, name)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("the dataset %s already exists", name)
	}

	// 创建数据集
	dataset := DataSet{
		Name:        name,
		Description: description,
		Hash:        hash,
		CreateTime:  createTime,
		UpdateTime:  updateTime,
	}

	// 将数据集转换为json格式
	datasetJSON, err := json.Marshal(dataset)
	if err != nil {
		return err
	}

	// 将数据集写入账本
	err = ctx.GetStub().PutState(dataset.Name, datasetJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	dataSetName = append(dataSetName, dataset.Name)
	return nil
}

// 获取当前所有数据集名称
func (s *SmartContract) GetAllDataSet(ctx contractapi.TransactionContextInterface) ([]string, error) {
	return dataSetName, nil
}


// 创建数据子集函数，传入数据集名称、数据子集名称、描述、hash、创建时间、更新时间、数据集价格，创建数据子集
func (s *SmartContract) CreateDataSubset(ctx contractapi.TransactionContextInterface, datasetName string, name string, description string, hash []string, createTime string, updateTime string, price int) error {
	//检查合约调用者是否为合约创建者
	currentID, _ := ctx.GetClientIdentity().GetID()
	if currentID != creatorID {
		return fmt.Errorf("the creator of the dataset is not the creator of the contract")
	}
	// 检查数据集是否存在
	exists, err := s.DataSetExists(ctx, datasetName)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the dataset %s does not exists", datasetName)
	}

	// 读取数据集
	dataset, err := s.ReadDataSet(ctx, datasetName)
	if err != nil {
		return err
	}

	// 创建数据子集
	datasubset := DataSubset{
		Name:        name,
		Description: description,
		Hash:        hash,
		CreateTime:  createTime,
		UpdateTime:  updateTime,
		Price:       price,
	}

	// 将数据子集添加到数据集中
	dataset.DataSubset = append(dataset.DataSubset, datasubset)

	// 将数据集转换为json格式
	datasetJSON, err := json.Marshal(dataset)
	if err != nil {
		return err
	}

	// 将数据集写入账本
	err = ctx.GetStub().PutState(dataset.Name, datasetJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}

	return nil
}


// 读取数据集函数，传入数据集名称，返回数据集
func (s *SmartContract) ReadDataSet(ctx contractapi.TransactionContextInterface, name string) (*DataSet, error) {
	//检查合约调用者是否为合约创建者
	currentID, _ := ctx.GetClientIdentity().GetID()
	if currentID != creatorID {
		return nil, fmt.Errorf("the creator of the dataset is not the creator of the contract")
	}
	// 读取数据集
	datasetJSON, err := ctx.GetStub().GetState(name)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if datasetJSON == nil {
		return nil, fmt.Errorf("the dataset %s does not exist", name)
	}

	// 将数据集转换为结构体
	var dataset DataSet
	err = json.Unmarshal(datasetJSON, &dataset)
	if err != nil {
		return nil, err
	}

	return &dataset, nil
}

// 读取数据子集函数，传入数据集名称、数据子集名称，返回数据子集
func (s *SmartContract) ReadDataSubset(ctx contractapi.TransactionContextInterface, datasetName string, datasubsetName string) (*DataSubset, error) {
	//检查合约调用者是否为合约创建者
	currentID, _ := ctx.GetClientIdentity().GetID()
	if currentID != creatorID {
		return nil, fmt.Errorf("the creator of the dataset is not the creator of the contract")
	}
	// 读取数据集
	dataset, err := s.ReadDataSet(ctx, datasetName)
	if err != nil {
		return nil, err
	}

	// 遍历数据集中的数据子集，找到数据子集
	for _, datasubset := range dataset.DataSubset {
		if datasubset.Name == datasubsetName {
			return &datasubset, nil
		}
	}

	return nil, fmt.Errorf("the datasubset %s does not exist", datasubsetName)
}

// 更新数据集函数，传入数据集名称、描述、hash、更新时间，更新数据集
func (s *SmartContract) UpdateDataSet(ctx contractapi.TransactionContextInterface, name string, description string, hash []string, updateTime string) error {
	//检查合约调用者是否为合约创建者
	currentID, _ := ctx.GetClientIdentity().GetID()
	if currentID != creatorID {
		return fmt.Errorf("the creator of the dataset is not the creator of the contract")
	}
	// 检查数据集是否存在
	exists, err := s.DataSetExists(ctx, name)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the dataset %s does not exists", name)
	}

	// 读取数据集
	dataset, err := s.ReadDataSet(ctx, name)
	if err != nil {
		return err
	}

	// 更新数据集
	dataset.Description = description
	dataset.Hash = hash
	dataset.UpdateTime = updateTime

	// 将数据集转换为json格式
	datasetJSON, err := json.Marshal(dataset)
	if err != nil {
		return err
	}

	// 将数据集写入账本
	err = ctx.GetStub().PutState(dataset.Name, datasetJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}

	return nil
}

// 更新数据子集函数，传入数据集名称、数据子集名称、描述、hash、更新时间、数据集价格，更新数据子集
func (s *SmartContract) UpdateDataSubset(ctx contractapi.TransactionContextInterface, datasetName string, name string, description string, hash []string, updateTime string, price int) error {
	// 检查数据集是否存在
	exists, err := s.DataSetExists(ctx, datasetName)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the dataset %s does not exists", datasetName)
	}

	// 读取数据集
	dataset, err := s.ReadDataSet(ctx, datasetName)
	if err != nil {
		return err
	}

	// 更新数据子集
	for i, datasubset := range dataset.DataSubset {
		if datasubset.Name == name {
			dataset.DataSubset[i].Description = description
			dataset.DataSubset[i].Hash = hash
			dataset.DataSubset[i].UpdateTime = updateTime
			dataset.DataSubset[i].Price = price
		}
	}

	// 将数据集转换为json格式
	datasetJSON, err := json.Marshal(dataset)
	if err != nil {
		return err
	}

	// 将数据集写入账本
	err = ctx.GetStub().PutState(dataset.Name, datasetJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}

	return nil
}

// 从数据集中删除数据子集
func (s *SmartContract) DeleteDataSubset(ctx contractapi.TransactionContextInterface, datasetName string, datasubsetName string) error {
	//检查合约调用者是否为合约创建者
	currentID, _ := ctx.GetClientIdentity().GetID()
	if currentID != creatorID {
		return fmt.Errorf("the creator of the dataset is not the creator of the contract")
	}
	// 检查数据集是否存在
	exists, err := s.DataSetExists(ctx, datasetName)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("the dataset %s does not exists", datasetName)
	}

	// 读取数据集
	dataset, err := s.ReadDataSet(ctx, datasetName)
	if err != nil {
		return err
	}

	// 删除数据子集
	for i, datasubset := range dataset.DataSubset {
		if datasubset.Name == datasubsetName {
			dataset.DataSubset = append(dataset.DataSubset[:i], dataset.DataSubset[i+1:]...)
		}
	}

	// 将数据集转换为json格式
	datasetJSON, err := json.Marshal(dataset)
	if err != nil {
		return err
	}

	// 将数据集写入账本
	err = ctx.GetStub().PutState(dataset.Name, datasetJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}

	return nil
}

