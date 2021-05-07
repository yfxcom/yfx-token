pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiSender {

    using SafeMath for uint;

    event TokenMultiSent(address token, uint total);
    event EthMultiSent(uint256 total);
   
   function ethSendSameValue(address payable[] calldata _to, uint256 _value) payable public  {

        uint sendAmount = _to.length.sub(1).mul(_value);
        uint remainingValue = msg.value;

        require(remainingValue >= sendAmount);
		require(_to.length <= 255);

		for (uint8 i = 1; i < _to.length; i++) {
			remainingValue = remainingValue.sub(_value);
			require(_to[i].send(_value));
		}

        emit EthMultiSent(msg.value);
    }

    function ethSendDifferentValue(address payable[] calldata _to, uint[] calldata _value) payable public  {

        uint sendAmount = _value[0];
		uint remainingValue = msg.value;

        require(remainingValue >= sendAmount);

		require(_to.length == _value.length);
		require(_to.length <= 255);

		for (uint8 i = 1; i < _to.length; i++) {
			remainingValue = remainingValue.sub(_value[i]);
			require(_to[i].send(_value[i]));
		}

        emit EthMultiSent(msg.value);
    }

    function coinSendSameValue(address _tokenAddress, address[] calldata _to, uint _value)  public {

		require(_to.length <= 255);
		
		address from = msg.sender;
		uint256 sendAmount = _to.length.sub(1).mul(_value);

        IERC20 token = IERC20(_tokenAddress);
		for (uint8 i = 1; i < _to.length; i++) {
			token.transferFrom(from, _to[i], _value);
		}

        emit TokenMultiSent(_tokenAddress, sendAmount);
	}

	function coinSendDifferentValue(address _tokenAddress, address[] calldata _to, uint[] calldata _value)  public  {
		require(_to.length == _value.length);
		require(_to.length <= 255);

        uint256 sendAmount = _value[0];
        IERC20 token = IERC20(_tokenAddress);
        
		for (uint8 i = 1; i < _to.length; i++) {
			token.transferFrom(msg.sender, _to[i], _value[i]);
		}

        emit TokenMultiSent(_tokenAddress, sendAmount);
	}
}