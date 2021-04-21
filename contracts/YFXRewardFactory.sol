pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./YFXReward.sol";

contract YFXRewardFactory is Ownable {
    event RewardCreated(address addr);

    function createReward(address owner, address stake, address reward, uint256 duration, uint256 lock) public onlyOwner {

        YFXReward _reward = new YFXReward();

        _reward.initReward(stake, reward, duration, lock);
        _reward.transferOwnership(owner);

        emit RewardCreated(address(_reward));
    }
}