pragma solidity ^0.4.4;

contract House {

    enum houseState { Poor, Mediocre, Good, Excellent }

    struct Bid {
        address bidder;
        uint bidValue;
        bool accepted;
        uint bidNumber;
        uint status; //status of the bid: 1 = submitted, 2 = accepted, 3 = rejected
    }

    uint public askingPrice;
    bool public isForSale;
    uint public soldPrice;
    bytes32 public streetAddress;
    address  public houseOwner;
    address public buyer;
    houseState public state;
    bool public inspected;
    address houseInspector;
    address mortgageLender;
    bool mortgageApproved;
    uint mortgageValue;
    address public bidder;
    uint public bidValue;
    uint public acceptedBid;
    mapping(uint => Bid) public bids;
    uint public bidIndex;
    uint public appraisalValue;
    bool public appraised;

    event InitHouse(address indexed ownerAddress);
    event HouseInitialized(address indexed ownerAddress);
    event HouseForSale(address indexed seller, uint indexed askingPrice, bytes32 indexed stAddress);
    event HouseNotForSale(address indexed seller, bytes32 indexed stAddress);
    event PriceChanged(address indexed seller, uint indexed askingPrice, bytes32 indexed stAddress);
    event BidPlaced(address indexed bidder, uint indexed biddingPrice);
    event BidRejected(address indexed bidder);
    event BidAccepted(address indexed bidder, uint indexed acceptedBid);
    event BidExists(address indexed bidder, uint indexed biddingPrice);
    event Inspected(address indexed inspector, uint indexed status);
    event MortgageApplied(address indexed lender, uint indexed value);
    event MortgageApproved(address indexed lender, uint indexed value);
    event MortgageRejected(address indexed lender, uint indexed value);
    event HouseSold(address indexed buyer, uint indexed price);
    event ChangedMortgageValue(uint indexed mortgageValue);
    event BidAlreadyExists(uint indexed biddingPrice);
    event BidAlreadyAccepted(uint indexed bidNumber);
    event NoBidsAccepted(uint indexed acceptedBid);
    event FoundBid(address indexed bidder, uint indexed bidNumber);
    event UpdatedBid(address indexed bidder, uint indexed bidNumber);
    event AllBidsDeleted();
    event GetBidIndexRequest(address indexed requestor);
    event GetBidRequest(address indexed requestor, uint indexed bindNumber);
    event AppraisalValueSet(address indexed appraiser, uint indexed value);
    event DeleteBids(uint indexed bidNumber);
    event BidsDeleted(uint indexed bidNumber, uint indexed acceptedBid);
    event Killed(address indexed from);
    event BidDeleted(address indexed from, uint indexed bidNumber);

    function House(bytes32 stAddress) {
        houseOwner = msg.sender;
        streetAddress = stAddress;
        isForSale = false;
        bidIndex = 1;
    }

    function forSale(uint price) {
        isForSale = true;
        askingPrice = price;
        HouseForSale(houseOwner, askingPrice, streetAddress);
    }

    function notForSale() {
        isForSale = false;
        askingPrice = 0;
        HouseNotForSale(houseOwner, streetAddress);
    }

    function changePrice(uint newPrice) {
        askingPrice = newPrice;
        PriceChanged(houseOwner, askingPrice, streetAddress);
    }
    
    function placeBid(uint biddingPrice) {
        if(isForSale) {
            bids[bidIndex].bidder = msg.sender;
            bids[bidIndex].bidValue = biddingPrice;
            bids[bidIndex].accepted = false;
            bids[bidIndex].bidNumber = bidIndex;
            bids[bidIndex].status = 1;
            bidIndex = bidIndex + 1;
            BidPlaced(msg.sender, biddingPrice);
        } else {
            HouseNotForSale(houseOwner, streetAddress);
        }
    }

    function checkBid(uint biddingPrice) constant returns(bool) {
        uint i;
        for(i = 1; i < bidIndex; i++) {
            if(bids[i].bidValue == biddingPrice) {
                return true;
            }
        }
        return false;
    }
    
    function acceptBid(address bidder) {
        uint i;
        if(acceptedBid == 0) {
            NoBidsAccepted(acceptedBid);
           for(i = 1; i < bidIndex; i++) {
                if(bids[i].bidder == bidder) {
                    FoundBid(bidder, bids[i].bidNumber);
                    bids[i].accepted = true;
                    bids[i].status = 2;
                    acceptedBid = bids[i].bidNumber;
                    isForSale = false;
                    i = bidIndex + 1;
                    UpdatedBid(bidder, acceptedBid);
                } else {
                    rejectBid(bids[i].bidder);
                }
            }
            BidAccepted(bids[acceptedBid].bidder, acceptedBid);
        } else {
            BidAlreadyAccepted(acceptedBid);
        }
    }

    function deleteAllBids() {
        uint i;
        for( i = 1; i < bidIndex; i++) {
            delete(bids[i]);
        }
        bidIndex = 1;
        AllBidsDeleted();
    }
    
    function deleteBid(uint bidNumber) {
        delete(bids[bidNumber]);
        bidIndex = bidIndex - 1;
        BidDeleted(msg.sender, bidNumber);
    }
    
    function rejectBid(address bidderAddress) {
        uint i;
        for(i = 1; i < bidIndex; i++) {
            if(bids[i].bidder == bidderAddress) {
                bids[i].accepted = false;
                bids[i].status = 3;
            }
        }
        BidRejected(bidderAddress);
    }
    
    function getBidIndex() constant returns(uint) {
        GetBidIndexRequest(msg.sender);
        return(bidIndex - 1);
    }
    
    function getBid(uint bidNumber) constant returns(address, uint, bool, uint, uint) {
        GetBidRequest(msg.sender, bidNumber);
        return(bids[bidNumber].bidder, bids[bidNumber].bidValue, bids[bidNumber].accepted, bids[bidNumber].bidNumber, bids[bidNumber].status);
    }

    function inspectionStatus(uint status) {
        if ( status == 0) {
            state = houseState.Poor;
        } else {
            if (status == 1) {
                state = houseState.Mediocre;
            } else {
                if ( status == 2) {
                    state = houseState.Good;
                } else {
                    if ( status == 3) {
                        state = houseState.Excellent;
                    }
                }
            }
        }
        houseInspector = msg.sender;
        inspected = true;
        Inspected(msg.sender, status);
    }

    function setAppraisalValue(uint value) {
        appraisalValue = value;
        appraised = true;
        AppraisalValueSet(msg.sender, value);
    }
    
    function applyMortgage(uint requestedMortgage) {
        uint i;
        if(appraisalValue >= requestedMortgage) {
            mortgageApproved = true;
            mortgageValue = requestedMortgage;
            soldPrice = bids[acceptedBid].bidValue;
            houseOwner = bids[acceptedBid].bidder;
            isForSale = false;
            askingPrice = 0;
            appraised = false;
            appraisalValue = 0;
            DeleteBids(bidIndex);
            for(i = 1; i < bidIndex; i++) {
                delete(bids[i]);
            }
            BidsDeleted(bidIndex, acceptedBid);
            bidIndex = 1;
            acceptedBid = 0;
            MortgageApproved(msg.sender, requestedMortgage);
            HouseSold(houseOwner, soldPrice);
        } else {
            MortgageRejected(msg.sender, requestedMortgage);
        }
    }

    function changeMortgageValue(uint changedMortgageValue) {
        mortgageValue = changedMortgageValue;
        ChangedMortgageValue(mortgageValue);
    }

    function rejectMortgage(uint value) {
        mortgageLender = msg.sender;
        mortgageApproved = false;
        mortgageValue = 0;
        MortgageRejected(msg.sender, value);
    }

    function sold() {
        if ( mortgageApproved && inspected ) HouseSold(buyer, soldPrice);
    }
    
    function kill() {
        if (msg.sender == houseOwner) {
            Killed(houseOwner);
            suicide(houseOwner);
        }
    }
}
