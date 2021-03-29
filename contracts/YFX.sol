// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IERC677.sol";
import "./interfaces/IERC2612.sol";

contract YFX is ERC20Capped, IERC677, IERC2612, Ownable {
    using SafeMath for uint256;

    bytes32 public override  DOMAIN_SEPARATOR;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    // keccak256("Transfer(address owner,address to,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 public constant TRANSFER_TYPEHASH = 0x42ce63790c28229c123925d83266e77c04d28784552ab68b350a9003226cbd59;

    address public emergencyRecipient;

    mapping(address => uint256) public  override nonces;

    constructor(address owner_, address emergencyRecipient_, string memory name_, string memory symbol_, uint256 cap_) ERC20Capped(cap_) ERC20(name_, symbol_) Ownable() public {
        emergencyRecipient = emergencyRecipient_;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function mint(address to, uint value) external onlyOwner {
        _mint(to, value);
    }

    function emergencyWithdraw(IERC20 token) external {
        token.transfer(emergencyRecipient, token.balanceOf(address(this)));
    }

    function transferWithPermit(address owner, address to, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(owner != address(0) && to != address(0), "zero address");
        require(block.timestamp <= deadline || deadline == 0, "expired transfer");

        bytes32 digest = keccak256(
            abi.encodePacked(
                uint16(0x1901),
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(TRANSFER_TYPEHASH, owner, to, value, nonces[owner]++, deadline))
            )
        );

        require(owner == ecrecover(digest, v, r, s), "invalid signature");
        _transfer(owner, to, value);
    }

    // implement the erc-2612
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external override {
        require(owner != address(0), "zero address");
        require(block.timestamp <= deadline || deadline == 0, "permit is expired");

        bytes32 digest = keccak256(
            abi.encodePacked(
                uint16(0x1901),
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );

        require(owner == ecrecover(digest, v, r, s), "invalid signature");
        _approve(owner, spender, value);
    }


    // implement the erc-677
    function transferAndCall(address to, uint value, bytes calldata data) external override returns (bool success) {
        _transfer(msg.sender, to, value);

        return ITransferReceiver(to).onTokenTransfer(msg.sender, value, data);
    }

    function approveAndCall(address spender, uint256 value, bytes calldata data) external override returns (bool success) {
        _approve(msg.sender, spender, value);

        return IApprovalReceiver(spender).onTokenApproval(msg.sender, value, data);
    }
}