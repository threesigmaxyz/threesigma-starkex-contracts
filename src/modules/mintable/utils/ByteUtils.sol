// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ByteUtils
/// @author StarkExpress Team
/// @notice Library for byte array manipulation.
library ByteUtils {
    //==============================================================================//
    //=== Errors                                                                 ===//
    //==============================================================================//

    /// @notice Thrown when the length of a byte array input it invalid.
    error InvalidBytesLength();

    //==============================================================================//
    //=== Utils                                                                  ===//
    //==============================================================================//

    /// @notice Converts a slice of `bytes` into a `uint256`.
    /// @dev The input `bytes_` must have a length of at least `(start_ + 32)` bytes.
    /// @param bytes_ The bytes to be converted.
    /// @param start_ The starting index of the slice.
    /// @return result_ The converted `uint256` value.
    function toUint256(bytes memory bytes_, uint256 start_) internal pure returns (uint256 result_) {
        if (bytes_.length < start_ + 32) {
            revert InvalidBytesLength();
        }

        assembly {
            result_ := mload(add(add(bytes_, 0x20), start_))
        }
    }
}
