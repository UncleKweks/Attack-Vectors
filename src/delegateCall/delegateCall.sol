// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DelegateCallVulnerable {
    address public implementation;
    address public owner;

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }

    receive() external payable {
        // Custom logic for receiving Ether can be added here
    }

    fallback() external payable {
        // Delegatecall to the implementation contract
        (bool success, ) = implementation.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    function updateImplementation(address newImplementation) external {
        require(msg.sender == owner, "Not authorized");
        implementation = newImplementation;
    }
}
