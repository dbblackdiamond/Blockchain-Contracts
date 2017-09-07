pragma solidity ^0.4.7;

contract Lease {
    
    struct Product {
        string name;
        string model;
        string image;
        uint price;
    }
    
    mapping(uint => Product) products;
    uint duration;
    bool assigned;
    uint numberOfProducts;
    uint value;
    
    function Lease() {
        assigned = false;
        duration = 0;
        numberOfProducts = 0;
        value = 0;
    }
    
    function setDuration(uint _duration) {
        duration = _duration;
    }
    
    function getDuration() constant returns(uint) {
        return(duration);
    }
    
    function assignLease() {
        assigned = true;
    }
    
    function getAssigned() constant returns(bool) {
        return(assigned);
    }
    
    function getValue() constant returns(uint) {
        return(value);
    }
    
    function addProduct(string _name, string _model, string _image, uint _price) {
        products[numberOfProducts].name = _name;
        products[numberOfProducts].model = _model;
        products[numberOfProducts].image = _image;
        products[numberOfProducts].price = _price;
        numberOfProducts++;
        value += _price;
    }
    
    function getNumberOfProducts() constant returns(uint) {
        return(numberOfProducts);
    }
    
    function getProduct(uint index) constant returns(string, string ,string, uint) {
        if(index >= 0 && index < numberOfProducts) {
            return(products[index].name, products[index].model, products[index].image, products[index].price);
        } else {
            return("","","", 0);
        }
    }
    
    function deleteAllProducts() {
        uint i;
        for(i = 0; i < numberOfProducts; i++) {
            delete(products[i]);
        }
    }
}


contract Security {

    struct Owner {
        string name;
        uint share;
    }
    

    mapping(uint => Owner) owners;
    mapping(uint => address) leases;
    string name;
    uint numberOfLeases;
    uint numberOfOwners;
    bool completed;
    
    function Security(string _name) {
        name = _name;
        completed = false;
        numberOfLeases = 0;
        numberOfOwners = 0;
    }
    
    function getName() constant returns(string) {
        return(name);
    }
    
    function setComplete() {
        completed = true;
    }
    
    function getCompleted() constant returns(bool) {
        return(completed);
    }
    
    function getNumberOfOwners() constant returns(uint) {
        return(numberOfOwners);
    }
    
    function getNumberOfLeases() constant returns(uint) {
        return(numberOfLeases);
    }
    
    function addOwner(string _name, uint _share) {
        owners[numberOfOwners].name = _name;
        owners[numberOfOwners].share = _share;
        numberOfOwners++;
    }
    
    function getOwner(uint index) constant returns(string, uint) {
        if(index >= 0 && index < numberOfOwners) {
            return(owners[index].name, owners[index].share);
        } else {
            return("", 0);
        }
    }
    
    function addLease(address _lease) {
        leases[numberOfLeases] = _lease;
        numberOfLeases ++;
    }
    
    function getLease(uint index) constant returns(address) {
        if(index >= 0 && index < numberOfLeases) {
            return(leases[index]);
        } else {
            return(0x0);
        }
    }
    
    function deleteAllOwners() {
        uint i;
        for (i = 0; i < numberOfOwners; i++) {
            delete(owners[i]);
        }
    }
    
    function deleteAllLeases() {
        uint i;
        for (i = 0; i < numberOfLeases; i++) {
            delete(leases[i]);
        }
    }
    

}
