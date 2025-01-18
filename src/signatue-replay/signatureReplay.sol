// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SignatureReplayVulnerable {
    address public owner;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner, bytes calldata signature) external {
        require(newOwner != address(0), "Invalid new owner");

        // Recreate the hash the owner must have signed
        bytes32 messageHash = keccak256(abi.encodePacked(newOwner));

        // Recover the signer of the hash
        address signer = recoverSigner(messageHash, signature);

        // Check if the signer is the current owner
        require(signer == owner, "Invalid signature");

        // Transfer ownership
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function recoverSigner(bytes32 messageHash, bytes calldata signature) public pure returns (address) {
        return ECDSA.recover(ECDSA.toEthSignedMessageHash(messageHash), signature);
    }
}
