// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

function toString(uint _i) pure returns (string memory _uintAsString) {
    if (_i == 0) {
        return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len;
    while (_i != 0) {
        k = k-1;
        uint8 temp = (48 + uint8(_i - _i / 10 * 10));
        bytes1 b1 = bytes1(temp);
        bstr[k] = b1;
        _i /= 10;
    }
    return string(bstr);
}

abstract contract Store is ERC1155, Ownable {
    bool public constant dcommerce = true;
    string public name;
    string public uriBase;
    mapping(uint256 => mapping(address => uint256)) public redeemed;

    constructor() ERC1155("") {}

    function setName(string calldata _name) public onlyOwner {
        name = _name;
    }
    function setUriBase(string calldata _uriBase) public onlyOwner {
        uriBase = _uriBase;
    }

    function uri(uint256 _id) override public view returns (string memory) {
        return string(abi.encodePacked(uriBase, toString(_id), ".json"));
    }

    function redeem(uint256 _id) public virtual {
        require(balanceOf(msg.sender, _id) - redeemed[_id][msg.sender] >= 1, "not enough balance");
        redeemed[_id][msg.sender] += 1;
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
            uint256 balance = balanceOf(from, ids[i]);
            require(balance - alreadyRedeemedAmount > amounts[i], "cannot transfer redeemed items");
        }
    }
}