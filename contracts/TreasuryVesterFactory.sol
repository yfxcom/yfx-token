pragma solidity >=0.6.0 <0.8.0;

import "./TreasuryVester.sol";

contract TreasuryVesterFactory {
    IERC20 public yfx;

    event VesterCreated(address indexed vester, address indexed recipient, uint256 vestingAmount);

    constructor(IERC20 _yfx) {
        yfx = _yfx;
    }

    function createVester(
        address recipient,
        uint256 vestingAmount,
        uint256 vestingBegin,
        uint256 vestingCliff,
        uint256 vestingEnd) external returns(address) {
        require(vestingAmount > 0, "vesting amount is zero");

        address vester = address(new TreasuryVester(address(yfx), recipient, vestingAmount, vestingBegin, vestingCliff, vestingEnd));

        yfx.transferFrom(msg.sender, vester, vestingAmount);

        emit VesterCreated(vester, recipient, vestingAmount);

        return vester;
    }
}