// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EntropyIllusion {
    address public winner;
    uint256 public lastRandomNumber;

    function determineWinner(address[] calldata participants) external {
        require(participants.length > 0, "No participants");

        // Attempt to generate randomness using block properties
        uint256 random = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        );

        lastRandomNumber = random;

        // Select a winner based on "randomness"
        uint256 winnerIndex = random % participants.length;
        winner = participants[winnerIndex];
    }
}

