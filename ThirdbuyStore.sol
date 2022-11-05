// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./Store.sol";

struct Listing {
    uint256 priceUSDC;
    uint256 amount;
    address owner;
}

contract ThirdbuyStore is Store {
    mapping(uint256 => Listing[]) public listings;

    constructor() Store() {}
    function list(uint256 id, uint256 amount, uint256 priceUSDC) public {
        require(amount <= balanceOf(msg.sender, id), "not enough balance");

        for(uint256 j = 0; j < listings[id].length; j++) {
            if(listings[id][j].owner == msg.sender && listings[id][j].priceUSDC == priceUSDC) {
                listings[id][j].amount += amount;
                return;
            }
        }
        listings[id].push(Listing({
            priceUSDC: priceUSDC,
            amount: amount,
            owner: msg.sender
        }));
    }
    function getListings(uint256 id) public view returns(Listing[] memory) {
        return listings[id];
    }
    function distributeProducts(uint256[] calldata ids, uint256[] calldata counts) public {
        require(msg.sender == owner, "unauthorized address");

        for(uint256 i = 0; i < ids.length; i++) {
            uint256 balance = balanceOf(msg.sender, ids[i]);
            uint256 difference = counts[i] - balance;
            if(difference < 0) {
                _burn(msg.sender, ids[i], balance - counts[i]);
            } else if (difference > 0) {
                _mint(msg.sender, ids[i], difference, "");
            }
        }
    }
}