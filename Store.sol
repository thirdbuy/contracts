// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract Store is ERC1155, ERC1155Burnable {
    bool public constant dcommerce = true;
    string public name;
    address public owner;
    constructor() ERC1155("") {
        owner = msg.sender;
    }
    function setName(string calldata _name) public {
        require(msg.sender == owner, "unauthorized address");

        name = _name;
    }
    function uri
}