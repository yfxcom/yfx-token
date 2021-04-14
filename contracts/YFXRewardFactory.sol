pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./YFXReward.sol";

contract YFXRewardFactory is Ownable {
    event RewardCreated(address addr);

    function createReward(address owner, address token, uint256 duration) public onlyOwner {

        YFXReward reward = new YFXReward();

        reward.initReward(token, duration);
        reward.transferOwnership(owner);

        emit RewardCreated(address(reward));
    }
}