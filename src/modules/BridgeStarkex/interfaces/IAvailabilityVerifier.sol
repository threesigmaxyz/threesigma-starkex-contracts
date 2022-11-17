// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.8.0;

interface IAvailabilityVerifier {
  /*
    Verifies the availability proof. Reverts if invalid.
  */
  function verifyAvailabilityProof(bytes32 claimHash, bytes calldata availabilityProofs) external;
}
