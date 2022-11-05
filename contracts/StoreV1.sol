// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ToString.sol";

abstract contract Store is ERC1155, Ownable {
    using ToString for uint256;

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
        return string(abi.encodePacked(uriBase, _id.toString(), ".json"));
    }

    function redeem(uint256 _id) public {
        require(balanceOf(msg.sender, _id) - redeemed[_id][msg.sender] >= 1, "not enough balance");
        redeemed[_id][msg.sender] += 1;
    }
    function getRedeemedBalance(address _owner, uint256 _id) public view returns(uint256) {
        return redeemed[_id][_owner];
    }

    function _beforeTokenTransfer(
        address _operator,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal override(ERC1155) {
        super._beforeTokenTransfer(_operator, _from, _to, _ids, _amounts, _data);
        for(uint256 i = 0; i < _ids.length; i++) {
            uint256 alreadyRedeemedAmount = redeemed[_ids[i]][_from];
            require(_amounts[i] > alreadyRedeemedAmount, "cannot transfer redeemed items");
        }
    }
}