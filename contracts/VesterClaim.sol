pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract VesterClaim {
    using SafeMath for uint256;

    address public yfx = 0xF55a93b613D172b86c2Ba3981a849DaE2aeCDE2f;

    mapping(address => uint256) public balances;
    
    event Claimed(uint256 amount);

    constructor() {
        balances[0xF55a93b613D172b86c2Ba3981a849DaE2aeCDE2f] = 1e21;
    }

    function claim() external {
        exec(msg.sender);
    }

    function claim(address vester) external {
        exec(vester);
    }

    function exec(address vester) internal {
        uint256 amount = balances[vester];
        require(amount > 0, "balance zero");
        require(IERC20(yfx).balanceOf(address(this)) >= amount, "yfx not enough");
        balances[vester] = 0;
        TransferHelper.safeTransfer(yfx, vester, amount);
        emit Claimed(amount);
    }
}
