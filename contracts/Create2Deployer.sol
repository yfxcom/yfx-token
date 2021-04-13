pragma solidity >=0.6.0 <0.8.0;
import "./YFX.sol";

contract Create2Deployer {
    event Deployed(address addr, uint256 salt);

    function deploy(bytes memory code, uint256 salt) public returns (address addr) {
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, salt);
    }

    function deployYFX(address owner) public {
        bytes memory bytecode = type(YFX).creationCode;
        bytes32 salt = keccak256(bytecode);

        address yfx = deploy(bytecode, uint256(salt));

        bytes4 SELECTOR = bytes4(keccak256(bytes('transferOwnership(address)')));
        (bool success, bytes memory data) = yfx.call(abi.encodeWithSelector(SELECTOR, owner));
        require(success && (data.length == 0), 'transferOwnership error');
    }
}