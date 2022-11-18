// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./StoreV1.sol";

struct Listing {
    uint256 priceCentsUSDC;
    uint256 amount;
    address owner;
}

struct DetailedBalanceOf {
    uint256 available;
    uint256 redeemed;
    uint256 listed;
}

contract ThirdbuyStore is Store {
    mapping(uint256 => Listing[]) public listings;
    mapping(address => bool) private ownerTransferApprovals;

    constructor() Store() {
        string memory contractAddress = Strings.toHexString(uint160(address(this)), 20);
        uriBase = string(abi.encodePacked("https://api.thirdbuy.com/", contractAddress, "/"));
    }

    function amountListed(uint256 _id, address _owner) private view returns(uint256) {
        uint256 selling = 0;
        for(uint256 j = 0; j < listings[_id].length; j++) {
            if(listings[_id][j].owner == _owner) {
                selling += listings[_id][j].amount;
            }
        }
        return selling;
    }

    function redeem(uint256 _id) public virtual override {
        require(balanceOf(msg.sender, _id) - amountListed(_id, msg.sender) - redeemed[_id][msg.sender] >= 1, "not enough balance");
        redeemed[_id][msg.sender] += 1;
    }
    function detailedBalanceOf(address _owner, uint256 _id) public view returns(DetailedBalanceOf memory) {
        uint256 redeemedAmount = redeemed[_id][msg.sender];
        uint256 listedAmount = amountListed(_id, _owner);
        uint256 total = balanceOf(_owner, _id);
        return DetailedBalanceOf({
            available: total - redeemedAmount - listedAmount,
            redeemed: redeemedAmount,
            listed: listedAmount
        });
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        if(from == address(0)) {
            return;
        }
        for(uint256 i = 0; i < ids.length; i++) {
            uint256 alreadyRedeemedAmount = redeemed[ids[i]][from];
            uint256 sellingAmount = amountListed(ids[i], from);
            uint256 balance = balanceOf(from, ids[i]);
            require(balance - sellingAmount - alreadyRedeemedAmount > amounts[i], "not enough balance");
        }
    }

    function list(uint256 _id, uint256 _amount, uint256 _priceCentsUSDC) public {
        uint256 balance = balanceOf(msg.sender, _id) - redeemed[_id][msg.sender];
        uint256 alreadySelling = 0;

        for(uint256 j = 0; j < listings[_id].length; j++) {
            if(listings[_id][j].owner == msg.sender) {
                alreadySelling += listings[_id][j].amount;
                require(alreadySelling + _amount <= balance, "not enough balance");
                if(listings[_id][j].priceCentsUSDC == _priceCentsUSDC) {
                    listings[_id][j].amount += _amount;
                    return;
                }
            }
        }
        listings[_id].push(Listing({
            priceCentsUSDC: _priceCentsUSDC,
            amount: _amount,
            owner: msg.sender
        }));
    }
    function getListings(uint256 _id) public view returns(Listing[] memory) {
        return listings[_id];
    }
    function endListing(address _owner, uint256 _id, uint256 _priceCentsUSDC) public {
        require(msg.sender == _owner || owner() == _owner, "unauthorized");
        for(uint256 j = 0; j < listings[_id].length; j++) {
            if(listings[_id][j].owner == _owner && listings[_id][j].priceCentsUSDC == _priceCentsUSDC) {
                listings[_id][j] = listings[_id][listings[_id].length - 1];
                listings[_id].pop();
                return;
            }
        }
    }
    function distributeProducts(uint256[] calldata _ids, uint256[] calldata _counts) public onlyOwner {
        for(uint256 i = 0; i < _ids.length; i++) {
            uint256 balance = balanceOf(msg.sender, _ids[i]);
            if(balance > _counts[i]) {
                _burn(msg.sender, _ids[i], balance - _counts[i]);
            } else if (_counts[i] > balance) {
                _mint(msg.sender, _ids[i], _counts[i] - balance, "");
            }
        }
    }
}