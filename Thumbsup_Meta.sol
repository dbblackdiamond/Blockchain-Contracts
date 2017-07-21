pragma solidity ^0.4.4;

contract MetaContract {
    
    struct Application {
        address contractAddress;
        string applicationName;
    }
    
    address private owner;
    mapping (uint => Application) public applications;
    uint private numberApplications;
    address private nullAddress;
    uint private maxApplications;
    
    event InitBioMarin(address indexed owner);
    event RequestApplicationAddress(address indexed owner, uint indexed applicationNumber);
    event GetApplicationAddress(address indexed owner, address indexed contractAddress);
    event GetApplicationAddressFailed(address indexed owner, uint indexed applicationNumber);
    event DeletingApplicationByNumber(address indexed owner, uint indexed applicationNumber);
    event ApplicationDeleted(uint indexed number);
    event DeleteAllApplications(address indexed owner);
    event AllApplicationsDeleted(address indexed owner, uint indexed applicationNumber);
    event AddingApplication(address indexed _address);
    event ShiftingApplications();
    event ApplicationsShifted();
    event ApplicationAdded(address indexed _address, uint indexed _number);
    event SearchingApplication(uint indexed _number);
    event ApplicationFound(address indexed _address, uint indexed _number);
    event ApplicationNotFound(uint indexed _number);
    event WrongNumber(uint indexed _number);
    event Killed(address indexed owner);
    
    function MetaContract(uint _maxApps) {
        owner = msg.sender;
        numberApplications = 0;
        maxApplications = _maxApps;
        nullAddress = 0x0000000000000000000000000000000000000000;
        InitBioMarin(msg.sender);
    }
    
    function getNumberApplications() constant returns(uint) {
        return(numberApplications);
    }
    
    function getMaxApplications() constant returns(uint) {
        return(maxApplications);
    }
    
    function getApplication(uint _number) constant returns(address, string) {
        RequestApplicationAddress(msg.sender, _number);
        if(applications[_number].contractAddress != nullAddress) {
            GetApplicationAddress(msg.sender, applications[_number].contractAddress);
            return(applications[_number].contractAddress, applications[_number].applicationName);
        } else {
            GetApplicationAddressFailed(msg.sender, _number);
            return(nullAddress, "");
        }
        return(nullAddress, "");
    }
    
    function addApplication(address _address, string _name) {
        uint i;
        AddingApplication(_address);
        if(numberApplications == maxApplications) {
            ShiftingApplications();
            for(i = 1; i < numberApplications; i++) {
                applications[i - 1].contractAddress = applications[i].contractAddress;
                applications[i - 1].applicationName = applications[i].applicationName;
            }
            ApplicationsShifted();
            applications[numberApplications - 1].contractAddress = _address;
            applications[numberApplications - 1].applicationName = _name;
        } else {
            applications[numberApplications].contractAddress = _address;
            applications[numberApplications].applicationName = _name;
            numberApplications += 1;

        }
        ApplicationAdded(_address, numberApplications);
    }

    function findApplicationByNumber(uint _number) constant returns(address, string) {
        SearchingApplication(_number);
        if(_number > 0) {
            if(_number <= numberApplications) {
                ApplicationFound(applications[_number].contractAddress, _number);
                return(applications[_number].contractAddress, applications[_number].applicationName);
            } else {
                ApplicationNotFound(_number);
                return(nullAddress, "");
            }
        }
        WrongNumber(_number);
        return(nullAddress, "");
    }
    
    function removeApplicationByNumber(uint _number) {
        DeletingApplicationByNumber(msg.sender, _number);
        if(_number <= numberApplications) {
            delete(applications[_number]);
        }
        ApplicationDeleted(_number);
    }
    
    function deleteAllApplications() {
        uint i;
        DeleteAllApplications(msg.sender);
        for(i = 0; i < numberApplications; i++) {
            removeApplicationByNumber(i);
        }
        numberApplications = 0;
        AllApplicationsDeleted(msg.sender, numberApplications);
    }
    
    function kill() {
        if (msg.sender == owner) {
            Killed(owner);
            suicide(owner);
        }
    }    
}
