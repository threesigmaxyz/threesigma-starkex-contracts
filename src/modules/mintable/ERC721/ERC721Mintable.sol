// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC165 } from "@openzeppelin/interfaces/IERC165.sol";
import { ERC721 }  from "@openzeppelin/token/ERC721/ERC721.sol";

import { Mintable }        from "src/modules/mintable/Mintable.sol";
import { IERC721Mintable } from "src/modules/mintable/ERC721/IERC721Mintable.sol";
import { ByteUtils }       from "src/modules/mintable/utils/ByteUtils.sol";

contract ERC721Mintable is ERC721, Mintable, IERC721Mintable {
    address public immutable starkEx;

    constructor(
        string memory name_,
        string memory symbol_,
        address starkEx_
    ) ERC721(name_, symbol_) {
        require(starkEx_ != address(0), "StarkEx must not be empty");
        starkEx = starkEx_;
    }

    modifier onlyStarkEx() {
        require(msg.sender == starkEx, "Function can only be called by StarkEx");
        _;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, Mintable, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mintFor(
        address to_,
        uint256 quantity_,
        bytes calldata mintingBlob_
    ) external override onlyStarkEx {
        // validate mint quantity
        require(quantity_ == 1, "Invalid mint quantity");

        // parse minting blob
        uint256 tokenId_ = ByteUtils.toUint256(mintingBlob_, 0);

        // emit event
        emit Minted(to_, tokenId_);

        // mint ERC721 token
        _safeMint(to_, tokenId_);
    }
}
