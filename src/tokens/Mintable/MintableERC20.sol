// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./../../access/Ownable.sol";
import "./IMintable.sol";
import "./../../libraries/Minting.sol";

abstract contract MintableERC20 is Ownable, IMintable {
    address public operator;
    mapping(uint256 => bytes) public blueprints;

    event AssetMinted(address to, uint256 id, bytes blueprint);

    constructor(address _owner, address _operator) public {
        operator = _operator;
        require(_owner != address(0), "Owner must not be empty");
        transferOwnership(_owner);
    }

    modifier onlyOwnerOrOperator() {
        require(msg.sender == operator || msg.sender == owner(), "Function can only be called by owner or Operator");
        _;
    }

    function mintFor(
        address user,
        uint256 quantity,
        bytes calldata mintingBlob
    ) external override onlyOwnerOrOperator {
        require(quantity > 0, "Mintable: invalid quantity");
        // TODO What are these used in ERC20?
        (uint256 id, bytes memory blueprint) = Minting.split(mintingBlob);
        _mintFor(user, id);
        blueprints[id] = blueprint;
        emit AssetMinted(user, id, blueprint);
    }

    function _mintFor(address to, uint256 quantity) internal virtual;
}
