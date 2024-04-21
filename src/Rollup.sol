// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./RollupVerifier.sol";
import "forge-std/console.sol";

// from RollupVerifier.sol generated by snarkjs
uint256 constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

interface IVerifier {
 function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[3] memory input
    ) external pure returns (bool r);
}

contract Rollup {
  uint stateHash; // State Hash
  IVerifier public immutable verifier;
  
  event StateChanged(uint newStateHash);

  constructor(uint _stateHash, address _verifier) {
      stateHash = _stateHash;
      verifier = IVerifier(_verifier);
  }

  function updateState(
    uint[2] calldata _pA,
    uint[2][2] calldata _pB,
    uint[2] calldata _pC,
    uint[16] calldata transactionList,
    uint _oldStateHash,
    uint _newStateHash
  ) external {
    require(stateHash == _oldStateHash, "Invalid old state hash");

    uint256 h = uint256(sha256(abi.encodePacked(transactionList)));
    h = addmod(h, 0, FIELD_SIZE);

    require(
      verifier.verifyProof(
        _pA, _pB, _pC, [h, _oldStateHash, _newStateHash])
        , "Verification failed"
    );
    stateHash = _newStateHash;
    emit StateChanged(stateHash);
  }

  function getStateHash() public view virtual returns (uint) {
    return stateHash;
  }
}