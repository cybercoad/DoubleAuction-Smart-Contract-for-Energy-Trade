// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DoubleAuction {
    uint private constant MAX_SIZE = 20; // maximum number of bids
    uint private constant AUCTION_INTERVAL = 30; // time in seconds

    struct Bid {
        address bidder;
        uint quantity;
        uint price;
        bool exists;
    }

    Bid[] private buyBids;
    Bid[] private sellBids;
    uint private lastAuctionTime;
    
    struct Result {
        address seller;
        address buyer;
        uint clearingPrice;
        uint quantityTraded;
    }

    Result[] private results;
    Result[] public auctionHistory;

    mapping(address => Bid) public hasPlacedBid;
    mapping(address => uint) public buyerBalances;
    mapping(address => uint) public sellerBalances;

    event BidPlaced(address indexed bidder, uint quantity, uint price, bool isBuyBid);
    event BidCancelled(address indexed bidder, uint quantity, uint price, bool isBuyBid);
    event AuctionExecuted(uint timestamp, uint matchedPairs);
    event PaymentReceived(address indexed buyer, uint amount);
    event Withdrawal(address indexed user, uint amount);

    // Reentrancy guard
    bool private locked;
    modifier nonReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyAfterInterval() {
        require(
            block.timestamp >= lastAuctionTime + AUCTION_INTERVAL,
            "Double auction can only be called once every 30 seconds."
        );
        _;
    }

    function addBuyer(uint quantity, uint price) external payable {
        require(!hasPlacedBid[msg.sender].exists, "Bid already placed");
        require(quantity > 0 && price > 0, "Invalid quantity or price");
        require(buyBids.length < MAX_SIZE, "Maximum number of buy bids reached");
        require(msg.value >= quantity * price, "Insufficient payment");

        Bid memory newBid = Bid(msg.sender, quantity, price, true);
        buyBids.push(newBid);
        hasPlacedBid[msg.sender] = newBid;
        buyerBalances[msg.sender] += msg.value;

        emit BidPlaced(msg.sender, quantity, price, true);
    }

    function getSellerBidStatus(address seller) public view returns (bool hasBid, uint256 bidCount, uint256 maxSize) {
        return (hasPlacedBid[seller].exists, sellBids.length, MAX_SIZE);
    }

    function addSeller(uint quantity, uint price) external {
        require(!hasPlacedBid[msg.sender].exists, "Bid already placed");
        require(quantity > 0 && price > 0, "Invalid quantity or price");
        require(sellBids.length < MAX_SIZE, "Maximum number of sell bids reached");

        Bid memory newBid = Bid(msg.sender, quantity, price, true);
        sellBids.push(newBid);
        hasPlacedBid[msg.sender] = newBid;

        emit BidPlaced(msg.sender, quantity, price, false);
    }

    function cancelBid() external {
        require(hasPlacedBid[msg.sender].exists, "No bid placed");

        Bid memory bid = hasPlacedBid[msg.sender];
        bool isBuyBid = false;

        for (uint i = 0; i < buyBids.length; i++) {
            if (buyBids[i].bidder == msg.sender) {
                buyBids[i] = buyBids[buyBids.length - 1];
                buyBids.pop();
                isBuyBid = true;
                break;
            }
        }

        if (!isBuyBid) {
            for (uint i = 0; i < sellBids.length; i++) {
                if (sellBids[i].bidder == msg.sender) {
                    sellBids[i] = sellBids[sellBids.length - 1];
                    sellBids.pop();
                    break;
                }
            }
        } else {
            uint refundAmount = buyerBalances[msg.sender];
            buyerBalances[msg.sender] = 0;
            payable(msg.sender).transfer(refundAmount);
        }

        delete hasPlacedBid[msg.sender];
        emit BidCancelled(msg.sender, bid.quantity, bid.price, isBuyBid);
    }

    function doubleAuction() external onlyAfterInterval nonReentrant {
        lastAuctionTime = block.timestamp;

        _sortBids(buyBids, true);
        _sortBids(sellBids, false);

        uint k = _findBreakevenIndex();
        require(k > 0, "No matching bids");

        uint auctionPrice = (buyBids[k - 1].price + sellBids[k - 1].price) / 2;

        for (uint i = 0; i < k; i++) {
            uint tradedQuantity = min(sellBids[i].quantity, buyBids[i].quantity);
            uint tradeAmount = tradedQuantity * auctionPrice;

            results.push(
                Result(
                    sellBids[i].bidder,
                    buyBids[i].bidder,
                    auctionPrice,
                    tradedQuantity
                )
            );

            auctionHistory.push(
                Result(
                    sellBids[i].bidder,
                    buyBids[i].bidder,
                    auctionPrice,
                    tradedQuantity
                )
            );

            buyerBalances[buyBids[i].bidder] -= tradeAmount;
            sellerBalances[sellBids[i].bidder] += tradeAmount;
        }

        emit AuctionExecuted(block.timestamp, k);
        _clearBidsAndResetMapping();
    }

    function getResults() external view returns (Result[] memory) {
        return results;
    }

    function getAuctionHistory() external view returns (Result[] memory) {
        return auctionHistory;
    }

    function getCurrentBids() external view returns (Bid[] memory, Bid[] memory) {
        return (buyBids, sellBids);
    }

    function getMatchedPair() external view returns (address matchedBuyerOrSeller, uint price, uint quantity) {
        for (uint i = 0; i < results.length; i++) {
            if (results[i].buyer == msg.sender) {
                return (results[i].seller, results[i].clearingPrice, results[i].quantityTraded);
            } else if (results[i].seller == msg.sender) {
                return (results[i].buyer, results[i].clearingPrice, results[i].quantityTraded);
            }
        }
        revert("No match found for this address");
    }

    function withdraw() external nonReentrant {
        uint buyerAmount = buyerBalances[msg.sender];
        uint sellerAmount = sellerBalances[msg.sender];
        require(buyerAmount > 0 || sellerAmount > 0, "No balance to withdraw");

        uint totalAmount = buyerAmount + sellerAmount;

        buyerBalances[msg.sender] = 0;
        sellerBalances[msg.sender] = 0;
        
        (bool success, ) = msg.sender.call{value: totalAmount}("");
        require(success, "Withdrawal failed");

        emit Withdrawal(msg.sender, totalAmount);
    }

    function _sortBids(Bid[] storage bids, bool descending) private {
        uint n = bids.length;
        for (uint i = 0; i < n - 1; i++) {
            for (uint j = 0; j < n - i - 1; j++) {
                if ((descending && bids[j].price < bids[j + 1].price) ||
                    (!descending && bids[j].price > bids[j + 1].price)) {
                    Bid memory temp = bids[j];
                    bids[j] = bids[j + 1];
                    bids[j + 1] = temp;
                }
            }
        }
    }

    function _findBreakevenIndex() private view returns (uint) {
        uint k = 0;
        while (
            k < buyBids.length &&
            k < sellBids.length &&
            buyBids[k].price >= sellBids[k].price
        ) {
            k++;
        }
        return k;
    }

    function _clearBidsAndResetMapping() private {
        for (uint i = 0; i < buyBids.length; i++) {
            delete hasPlacedBid[buyBids[i].bidder];
        }
        for (uint i = 0; i < sellBids.length; i++) {
            delete hasPlacedBid[sellBids[i].bidder];
        }
        delete buyBids;
        delete sellBids;
    }

    // Helper function to replace Math.min
    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}