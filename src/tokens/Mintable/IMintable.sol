// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IMintable {
    function mintFor(
        address to,
        uint256 quantity,
        bytes calldata mintingBlob
    ) external;
}
