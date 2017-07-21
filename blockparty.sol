pragma solidity ^0.4.4;

contract Blockparty {
    
    struct House {
        address contractAddress;
        uint number;
        bytes32 streetAddress;
    }
    
    address private owner;
    mapping (uint => House) public houses;
    uint private numberHouses;
    address private nullAddress;
    
    event InitRealEstate(address indexed sender);
    event AddHouse(address indexed sender, address indexed contractAddress);
    event HouseNumberTooHigh(address indexed sender, uint indexed number);
    event HouseNumberTooLow(address indexed sender, uint indexed number);
    event AddHouseByNumber(address indexed sender, address indexed contractAddress, uint indexed number);
    event RequestHouseAddress(address indexed sender, uint indexed number);
    event RequestHouseNumber(address indexed sender, address indexed contractAddress);
    event GetHouseAddress(address indexed sender, address indexed contractAddress);
    event GetHouseAddressFailed(address indexed sender, uint indexed number);
    event HouseAlreadyExists(address indexed sender, address indexed contractAddress, uint indexed number);
    event HouseAdded(address indexed sender, address indexed contractAddress, uint indexed number, uint numberHouses);
    event SearchHouseByAddress(address indexed sender, address indexed contractAddress);
    event FoundHouse(address indexed sender, address indexed contractAddress, uint indexed number);
    event SearchHouseByNumber(address indexed sender, uint indexed number);
    event HouseNumberNotExist(address indexed sender, uint indexed number);
    event HouseNotFound(address indexed sender, address indexed contractAddress, uint indexed number);
    event NoHouse(address indexed sender);
    event RemovingHouseByAddress(address indexed sender, address indexed contractAddress);
    event RemovingHouseByNumber(address indexed sender, uint indexed number);
    event HouseNotExist(address indexed sender, address indexed contractAddress);
    event HouseRemoved(address indexed sender, address indexed contractAddress, uint indexed houseNumber);
    event ProblemRemovingHouse(address indexed sender, address indexed contractAddress);
    event DeleteAllHouses(address indexed sender);
    event AllHousesDeleted(address indexed sender, uint indexed number);
    event Killed(address indexed from);
    
    function RealEstate() {
        owner = msg.sender;
        numberHouses = 0;
        nullAddress = 0x0000000000000000000000000000000000000000;
        InitRealEstate(msg.sender);
    }
    
    function getNumberHouses() constant returns(uint) {
        return(numberHouses);
    }
    
    function getHouseAddress(uint houseNumber) constant returns(address) {
        RequestHouseAddress(msg.sender, houseNumber);
        if(houses[houseNumber].contractAddress != nullAddress) {
            GetHouseAddress(msg.sender, houses[houseNumber].contractAddress);
            return(houses[houseNumber].contractAddress);
        } else {
            GetHouseAddressFailed(msg.sender, houseNumber);
            return(nullAddress);
        }
        return(nullAddress);
    }
    
    function getHouseNumber(address contractAddress) constant returns(uint) {
        uint i;
        RequestHouseNumber(msg.sender, contractAddress);
        for(i = 1; i <= numberHouses; i++) {
            if(houses[i].contractAddress == contractAddress) {
                FoundHouse(msg.sender, houses[i].contractAddress, houses[i].number);
                return(houses[i].number);
            }
        }
        HouseNotFound(msg.sender, contractAddress, 0);
    }
    
    //The house will be added at a specific place
    function addHouseByNumber(uint number, address contractAddress) {
        uint i;
        AddHouseByNumber(msg.sender, contractAddress, number);
        if(number != 0) { 
            if(number <= numberHouses + 1) {
                for(i = numberHouses; i > number; i--) {
                    houses[i+1].contractAddress = houses[i].contractAddress;
                    houses[i+1].number = houses[i].number + 1;
                    houses[i+1].streetAddress = houses[i].streetAddress;
                }
                delete(houses[number]);
                houses[number].contractAddress = contractAddress;
                houses[number].number = number;
                numberHouses += 1;
                HouseAdded(msg.sender, houses[number].contractAddress, houses[number].number, numberHouses);
            } else {
                HouseNumberTooHigh(msg.sender, number);
            }
        } else {
            HouseNumberTooLow(msg.sender, number);
        }
    }
    
    //In this function, the house will always be address at the end
    function addHouseByAddress(address contractAddress) {
        uint houseExists;
        AddHouse(msg.sender, contractAddress);
        houseExists = findHouseByAddress(contractAddress);
        if(houseExists == 0) {
            numberHouses += 1;
            houses[numberHouses].contractAddress = contractAddress;
            houses[numberHouses].number = numberHouses;
            HouseAdded(msg.sender, houses[numberHouses].contractAddress, houses[numberHouses].number, numberHouses);
        } else {
            HouseAlreadyExists(msg.sender, houses[houseExists].contractAddress, houseExists);
        }
    }
    
    function findHouseByAddress(address contractAddress) constant returns(uint) {
        uint i;
        SearchHouseByAddress(msg.sender, contractAddress);
        if(numberHouses > 0) {
            for(i = 1; i <= numberHouses; i++) {
                if(houses[i].contractAddress == contractAddress) {
                    FoundHouse(msg.sender, houses[i].contractAddress, i);
                    return(i);
                }
            }
            HouseNotFound(msg.sender, contractAddress, 0);
            return(0);
        } else {
            NoHouse(msg.sender);
            return(0);
        }
    }
    
    function findHouseByNumber(uint number) constant returns(address) {
        uint i;
        SearchHouseByNumber(msg.sender, number);
        if(houses[number].contractAddress == nullAddress) {
            HouseNumberNotExist(msg.sender, number);
            return(nullAddress);
        } else {
            FoundHouse(msg.sender, houses[number].contractAddress, houses[number].number);
            return(houses[number].contractAddress);
        }
    }
    
    function removeHouseByAddress(address contractAddress) {
        uint houseIndex;
        uint i;
        RemovingHouseByAddress(msg.sender, contractAddress);
        houseIndex = findHouseByAddress(contractAddress);
        if(houseIndex == 0) {
            HouseNotExist(msg.sender, contractAddress);
            return;
        } else {
            delete(houses[houseIndex]);
            for(i = houseIndex; i < numberHouses; i++) {
                houses[i].contractAddress = houses[i+1].contractAddress;
                houses[i].number = houses[i+1].number - 1;
                houses[i].streetAddress = houses[i+1].streetAddress;
            }
            delete(houses[numberHouses]);
            numberHouses -= 1;
            HouseRemoved(msg.sender, contractAddress, houseIndex);
            return;
        }
        ProblemRemovingHouse(msg.sender, contractAddress);
    }
    
    function removeHouseByNumber(uint houseNumber) {
        uint i;
        address contractAddress;
        RemovingHouseByNumber(msg.sender, houseNumber);
        contractAddress = findHouseByNumber(houseNumber);
        if(contractAddress == nullAddress) {
            HouseNotFound(msg.sender, contractAddress, houseNumber);
        } else {
            removeHouseByAddress(contractAddress);
        }
    }
    
    function deleteAllHouses() {
        uint i;
        DeleteAllHouses(msg.sender);
        for(i = 1; i <= numberHouses; i++) {
            if(houses[i].contractAddress != nullAddress) {
                removeHouseByAddress(houses[i].contractAddress);
            }
        }
        AllHousesDeleted(msg.sender, numberHouses);
    }
    
    function kill() {
        if (msg.sender == owner) {
            Killed(owner);
            suicide(owner);
        }
    }    
}
