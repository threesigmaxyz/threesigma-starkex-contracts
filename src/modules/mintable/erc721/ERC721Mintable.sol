// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { OwnableUpgradeable } from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import { ERC721Upgradeable } from "@openzeppelin-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import { IMintable } from "../core/IMintable.sol";
import { MintableUpgradeable } from "../core/MintableUpgradeable.sol";
import { ByteUtils } from "../utils/ByteUtils.sol";

/// @title ERC721Mintable
/// @author StarkExpress Team
/// @notice Base implementation for StarkExpress ERC-721 mintable tokens.
contract ERC721Mintable is ERC721Upgradeable, MintableUpgradeable, OwnableUpgradeable {
    //==============================================================================//
    //=== Errors                                                                 ===//
    //==============================================================================//

    /// @notice Thrown when an invalid mint amount is requested.
    error InvalidMintAmountError();

    //==============================================================================//
    //=== Events                                                                 ===//
    //==============================================================================//

    /// @notice Emitted when the token's URI is set.
    /// @param uri_ The new token URI.
    event LogSetUri(string uri_);

    /// @notice Emitted when an ERC721 token is minted.
    /// @param to_ The minted token recipient.
    /// @param tokenId_ The minted token ID.
    event LogMintedERC721(address indexed to_, uint256 tokenId_);

    //==============================================================================//
    //=== State Variables                                                        ===//
    //==============================================================================//

    /// @notice The token's URI.
    string private _uri;

    //==============================================================================//
    //=== Initialization                                                         ===//
    //==============================================================================//

    /// @notice Initialization function for the `ERC721Mintable` contract.
    /// @param name_ The token's name.
    /// @param symbol_ The token's symbol.
    /// @param uri_ The token's URI.
    /// @param starkEx_ The StarkEx contract address.
    function initialize(string memory name_, string memory symbol_, string memory uri_, address starkEx_)
        external
        initializer
    {
        __ERC721_init(name_, symbol_);
        __Mintable_init(starkEx_);
        __Ownable_init();

        setUri(uri_);
    }

    //==============================================================================//
    //=== Read API                                                               ===//
    //==============================================================================//

    /// @inheritdoc MintableUpgradeable
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, MintableUpgradeable)
        returns (bool)
    {
        return ERC721Upgradeable.supportsInterface(interfaceId) ||
            MintableUpgradeable.supportsInterface(interfaceId);
    }

    //==============================================================================//
    //=== Write API                                                              ===//
    //==============================================================================//

    /// @notice Sets the token's URI.
    /// @dev Only callable by the owner.
    /// @param uri_ The new token URI.
    function setUri(string memory uri_) public onlyOwner {
        _uri = uri_;

        emit LogSetUri(uri_);
    }

    /// @inheritdoc IMintable
    /// @dev Only callable by the StarkEx contract.
    function mintFor(address to_, uint256 amount_, bytes calldata mintingBlob_) external override onlyStarkEx {
        // validate mint amount
        if (amount_ != 1) {
            revert InvalidMintAmountError();
        }

        // parse minting blob
        uint256 tokenId_ = ByteUtils.toUint256(mintingBlob_, 0);

        // emit event
        emit LogMintedERC721(to_, tokenId_);

        // mint ERC721 token
        _safeMint(to_, tokenId_);
    }

    //==============================================================================//
    //=== Internals                                                              ===//
    //==============================================================================//

    /// @dev See {IERC721Metadata-tokenURI}.
    function _baseURI() internal view override returns (string memory) {
        return _uri;
    }
}
