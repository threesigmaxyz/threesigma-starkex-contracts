// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.0;

import "../components/MessageRegistry.sol";

contract DepositRegistry is MessageRegistry {
  event DepositRegistered(
    address userAddress,
    address exchangeAddress,
    uint256 tokenId,
    uint256 amount,
    uint256 nonce,
    uint256 expirationTimestamp
  );

  uint256 constant MASK_32 = 0xFFFFFFFF;
  uint256 constant MASK_64 = 0xFFFFFFFFFFFFFFFF;
  uint256 constant LIMIT_ORDER_TYPE = 0x3;

  function identify() external pure override returns (string memory) {
    return "StarkWare_OrderRegistry_2021_1";
  }

  function calcDepositHash(
    uint256 tokenId,
    uint256 amount,
    uint256 nonce,
    uint256 expirationTimestamp
  ) public pure returns (bytes32) {
    uint256 packed_word0 = amount & MASK_64;
    packed_word0 = (packed_word0 << 32) + (nonce & MASK_32);

    uint256 packed_word1 = LIMIT_ORDER_TYPE;
    packed_word1 = (packed_word1 << 32) + (expirationTimestamp & MASK_32);
    packed_word1 = packed_word1 << 17;

    return
    keccak256(
      abi.encode(
        [
        bytes32(tokenId),
        bytes32(packed_word0),
        bytes32(packed_word1)
        ]
      )
    );
  }

  function depositOrder(
    address exchangeAddress,
    uint256 tokenId,
    uint256 amount,
    uint256 nonce,
    uint256 expirationTimestamp
  ) external {
    bytes32 depositHash = calcDepositHash(
      tokenId,
      amount,
      nonce,
      expirationTimestamp
    );
    registerMessage(exchangeAddress, depositHash);

    emit DepositRegistered(
      msg.sender,
      exchangeAddress,
      tokenId,
      amount,
      nonce,
      expirationTimestamp
    );
  }
}
