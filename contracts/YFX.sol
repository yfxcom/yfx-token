// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IERC677.sol";
import "./interfaces/IERC2612.sol";

contract YFX is ERC20, IERC677, IERC2612, Ownable {
    using SafeMath for uint256;

    uint256 public constant cap = 100_000_000e18; // CAP is 100,000,000 YFX

    bytes32 public override  DOMAIN_SEPARATOR;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    // keccak256("Transfer(address owner,address to,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 public constant TRANSFER_TYPEHASH = 0x42ce63790c28229c123925d83266e77c04d28784552ab68b350a9003226cbd59;

    address public emergencyRecipient;

    address public minter;

    mapping(address => uint256) public  override nonces;

    struct LockAddress {
        address recipient;
        uint256 vestingAmount;
        uint256 balance;
        uint256 vestingBegin;
        uint256 vestingCliff;
        uint256 vestingEnd;
        uint256 lastUpdate;
    }

    mapping(address => LockAddress) public locks;

    event MinterChanged(address minter, address newMinter);

    constructor(address _owner, address _emergencyRecipient, string memory _name, string memory _symbol) ERC20(_name, _symbol) Ownable() public {
        minter = _owner;
        emergencyRecipient = _emergencyRecipient;

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

    modifier onlyMinter {
        require(msg.sender == minter, "not minter");
        _;
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function emergencyWithdraw(IERC20 token) external {
        token.transfer(emergencyRecipient, token.balanceOf(address(this)));
    }

    function setMinter(address newMinter) external onlyOwner {
        emit MinterChanged(minter, newMinter);
        minter = newMinter;
    }

    function mint(address to, uint256 amount) external onlyMinter {
        require(totalSupply().add(amount) <= cap, "cap exceeded");
        _mint(to, amount);
    }

    function addTokenLockAddress(address _recipient, uint256 _vestingAmount, uint256 _vestingBegin, uint256 _vestingCliff, uint256 _vestingEnd) external onlyMinter {
        require(_vestingAmount > 0, "vesting amount is zero");
        require(_vestingBegin >= block.timestamp, "vesting begin too early");
        require(_vestingCliff >= _vestingBegin, "cliff is too early");
        require(_vestingEnd > _vestingCliff, "end is too early");

        require(totalSupply().add(_vestingAmount) <= cap, "cap exceeded");
        _mint(address(this), _vestingAmount);

        locks[_recipient] = LockAddress(
            _recipient,
            _vestingAmount,
            _vestingAmount,
            _vestingBegin,
            _vestingCliff,
            _vestingEnd,
            _vestingBegin
        );
    }

    function vested(address _recipient) external view returns (uint256) {
        LockAddress storage lockAddress = locks[_recipient];
        require(lockAddress.vestingAmount != 0, 'not exit');
        if (block.timestamp < lockAddress.vestingCliff) {
            return 0;
        }

        if (block.timestamp >= lockAddress.vestingEnd) {
            return lockAddress.balance;
        } else {
            return lockAddress.vestingAmount.mul(block.timestamp - lockAddress.lastUpdate).div(lockAddress.vestingEnd.sub(lockAddress.vestingBegin));
        }
    }

    function claim() external {
        LockAddress storage lockAddress = locks[msg.sender];
        require(lockAddress.vestingAmount != 0, 'not exit');
        require(block.timestamp >= lockAddress.vestingCliff, "not time yet");
        uint256 amount = this.vested(msg.sender);

        if (amount > 0) {
            require(amount <= lockAddress.balance, 'Insufficient balance');
            lockAddress.lastUpdate = block.timestamp;
            lockAddress.balance = lockAddress.balance.sub(amount);
            _transfer(address(this), msg.sender, amount);
        }
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
