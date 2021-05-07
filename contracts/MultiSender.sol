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

contract MultiSender {

    using SafeMath for uint;

    event TokenMultiSent(address token, uint total);
    event EthMultiSent(uint256 total);
   
   function ethSendSameValue(address payable[] calldata _to, uint256 _value) payable public  {

        uint sendAmount = _to.length.sub(1).mul(_value);
        uint remainingValue = msg.value;

        require(remainingValue >= sendAmount, "eth not enough");
		require(_to.length <= 255, "too many");

		for (uint8 i = 1; i < _to.length; i++) {
			remainingValue = remainingValue.sub(_value);
			require(_to[i].send(_value), "eth send fail");
		}

        emit EthMultiSent(msg.value);
    }

    function ethSendDifferentValue(address payable[] calldata _to, uint[] calldata _value) payable public  {

        uint sendAmount = _value[0];
		uint remainingValue = msg.value;

        require(remainingValue >= sendAmount, "eth not enough");

		require(_to.length == _value.length, "lenght not equal");
		require(_to.length <= 255, "too many");

		for (uint8 i = 1; i < _to.length; i++) {
			remainingValue = remainingValue.sub(_value[i]);
			require(_to[i].send(_value[i]), "eth send fail");
		}

        emit EthMultiSent(msg.value);
    }

    function coinSendSameValue(address _tokenAddress, address[] calldata _to, uint _value)  public {

		require(_to.length <= 255, "too many");
		
		address from = msg.sender;
		uint256 sendAmount = _to.length.sub(1).mul(_value);

        IERC20 token = IERC20(_tokenAddress);

        require(token.balanceOf(from) >= sendAmount, "balance not enough");

		for (uint8 i = 1; i < _to.length; i++) {
            TransferHelper.safeTransferFrom(from, _to[i], _value);
		}

        emit TokenMultiSent(_tokenAddress, sendAmount);
	}

	function coinSendDifferentValue(address _tokenAddress, address[] calldata _to, uint[] calldata _value)  public  {
		require(_to.length == _value.length, "lenght not equal");
		require(_to.length <= 255, "too many");

        uint256 sendAmount = _value[0];
        
        IERC20 token = IERC20(_tokenAddress);

        require(token.balanceOf(from) >= sendAmount, "balance not enough");
        
		for (uint8 i = 1; i < _to.length; i++) {
            TransferHelper.safeTransferFrom(msg.sender, _to[i], _value[i]);
		}

        emit TokenMultiSent(_tokenAddress, sendAmount);
	}
}