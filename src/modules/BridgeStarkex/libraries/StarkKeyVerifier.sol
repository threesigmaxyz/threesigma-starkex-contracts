pragma solidity >=0.5.3 <0.9.0; // NOLINT pragma.

import "../mixins/Constants.sol";


library StarkKeyVerifier{

  uint256 constant K_MODULUS = 0x800000000000011000000000000000000000000000000000000000000000001;

  uint256 constant K_BETA = 0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89;

  function fieldPow(uint256 base, uint256 exponent) internal view returns (uint256) {
    // NOLINTNEXTLINE: low-level-calls reentrancy-events reentrancy-no-eth.
    (bool success, bytes memory returndata) = address(5).staticcall(
      abi.encode(0x20, 0x20, 0x20, base, exponent, K_MODULUS)
    );
    require(success, string(returndata));
    return abi.decode(returndata, (uint256));
  }

  function isQuadraticResidue(uint256 fieldElement) internal view returns (bool) {
    return 1 == fieldPow(fieldElement, ((K_MODULUS - 1) / 2));
  }


  function isOnCurve(uint256 starkKey) internal view returns (bool) {
    uint256 xCubed = mulmod(mulmod(starkKey, starkKey, K_MODULUS), starkKey, K_MODULUS);
    return isQuadraticResidue(addmod(addmod(xCubed, starkKey, K_MODULUS), K_BETA, K_MODULUS));
  }


}
