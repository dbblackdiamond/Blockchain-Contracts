pragma solidity ^0.4.7;

contract MetaContract {
    
    address private owner;
    mapping (uint => address) public contracts;
    uint private numberOfContracts;
    uint private maxContracts;
    
    event Killed(address _owner);
    
    function MetaContract(uint _maxContracts) {
        owner = msg.sender;
        numberOfContracts = 0;
        maxContracts = _maxContracts;
    }
    
    function getNumberOfContracts() constant returns(uint) {
        return(numberOfContracts);
    }
    
    function getMaxContracts() constant returns(uint) {
        return(maxContracts);
    }
    
    function getContract(uint index) constant returns(address) {
        if(contracts[index] != 0x0) {
            return(contracts[index]);
        } else {
            return(0x0);
        }
        return(0x0);
    }
    
    function addContract(address _address) {
        uint i;
        if(numberOfContracts == maxContracts) {
            for(i = 1; i < numberOfContracts; i++) {
                contracts[i - 1] = contracts[i];
            }
            contracts[numberOfContracts - 1] = _address;
        } else {
            contracts[numberOfContracts] = _address;
            numberOfContracts += 1;

        }
    }

    function findContractByNumber(uint index) constant returns(address) {
        if(index > 0) {
            if(index <= numberOfContracts) {
                return(contracts[index]);
            } else {
                return(0x0);
            }
        }
        return(0x0);
    }
    
    function deleteContractByNumber(uint index) {
        if(index <= numberOfContracts) {
            delete(contracts[index]);
        }
    }
    
    function deleteAllContracts() {
        uint i;
        for(i = 0; i < numberOfContracts; i++) {
            deleteContractByNumber(i);
        }
        numberOfContracts = 0;
    }
    
    function kill() {
        if (msg.sender == owner) {
            Killed(owner);
            suicide(owner);
        }
    }    
}
