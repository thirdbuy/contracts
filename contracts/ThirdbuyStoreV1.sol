// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ToString.sol";
import "./StoreV1.sol";

struct Listing {
    uint256 priceUSDC;
    uint256 amount;
    address owner;
}

contract ThirdbuyStore is Store {
    using ToString for uint256;

    mapping(uint256 => Listing[]) public listings;
    mapping(address => bool) private ownerTransferApprovals;

    constructor() Store() {
        uriBase = string(abi.encodePacked("https://api.thirdbuy.com/", abi.encodePacked(address(this)), "/"));
    }

    function list(uint256 _id, uint256 _amount, uint256 _priceUSDC) public {
        require(_amount <= balanceOf(msg.sender, _id), "not enough balance");

        for(uint256 j = 0; j < listings[_id].length; j++) {
            if(listings[_id][j].owner == msg.sender && listings[_id][j].priceUSDC == _priceUSDC) {
                listings[_id][j].amount += _amount;
                return;
            }
        }
        listings[_id].push(Listing({
            priceUSDC: _priceUSDC,
            amount: _amount,
            owner: msg.sender
        }));
    }
    function getListings(uint256 _id) public view returns(Listing[] memory) {
        return listings[_id];
    }
    function endListing(address _owner, uint256 _id, uint256 _priceUSDC) public {
        require(msg.sender == _owner || owner() == _owner, "unauthorized");
        for(uint256 j = 0; j < listings[_id].length; j++) {
            if(listings[_id][j].owner == _owner && listings[_id][j].priceUSDC == _priceUSDC) {
                listings[_id][j] = listings[_id][listings[_id].length - 1];
                listings[_id].pop();
                return;
            }
        }
    }
    function distributeProducts(uint256[] calldata _ids, uint256[] calldata _counts) public onlyOwner {
        for(uint256 i = 0; i < _ids.length; i++) {
            uint256 balance = balanceOf(msg.sender, _ids[i]);
            uint256 difference = _counts[i] - balance;
            if(difference < 0) {
                _burn(msg.sender, _ids[i], balance - _counts[i]);
            } else if (difference > 0) {
                _mint(msg.sender, _ids[i], difference, "");
            }
        }
    }
}