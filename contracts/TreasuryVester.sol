pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TreasuryVester {
    using SafeMath for uint;

    address public yfx;
    address public recipient;

    uint256 public vestingAmount;
    uint256 public vestingBegin;
    uint256 public vestingCliff;
    uint256 public vestingEnd;

    uint256 public lastUpdate;

    constructor(
        address _yfx,
        address _recipient,
        uint256 _vestingAmount,
        uint256 _vestingBegin,
        uint256 _vestingCliff,
        uint256 _vestingEnd
    ) {
        require(_vestingAmount > 0, "vesting amount is zero");
        require(_vestingBegin >= block.timestamp, "vesting begin too early");
        require(_vestingCliff >= _vestingBegin, "cliff is too early");
        require(_vestingEnd > _vestingCliff, "end is too early");

        yfx = _yfx;
        recipient = _recipient;

        vestingAmount = _vestingAmount;
        vestingBegin = _vestingBegin;
        vestingCliff = _vestingCliff;
        vestingEnd = _vestingEnd;

        lastUpdate = vestingBegin;
    }

    function setRecipient(address _recipient) external {
        require(msg.sender == recipient, "unauthorized");
        recipient = _recipient;
    }

    function vested() public view returns(uint256) {
        if( block.timestamp < vestingCliff) {
            return 0;
        }
        
        if (block.timestamp >= vestingEnd) {
            return IERC20(yfx).balanceOf(address(this));
        } else {
            return vestingAmount.mul(block.timestamp - lastUpdate).div(vestingEnd.sub(vestingBegin));
        }
    }

    function claim() external {
        require(block.timestamp >= vestingCliff, "not time yet");
        uint256 amount = vested();

        if (amount > 0) {
            lastUpdate = block.timestamp;
            IERC20(yfx).transfer(recipient, amount);
        }
    }
}