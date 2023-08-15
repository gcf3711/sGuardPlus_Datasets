pragma solidity ^0.4.19;

contract sGuardPlus {
    constructor() internal {
        __lock_modifier0_lock = false;
    }

    function sub_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    bool private __lock_modifier0_lock;
    modifier __lock_modifier0() {
        require(!__lock_modifier0_lock);
        __lock_modifier0_lock = true;
        _;
        __lock_modifier0_lock = false;
    }
}

contract Ownable {
    address newOwner;
    address owner = msg.sender;

    function changeOwner(address addr) public onlyOwner {
        newOwner = addr;
    }

    function confirmOwner() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }

    modifier onlyOwner() {
        if (owner == msg.sender) _;
    }
}

contract Token is Ownable {
    address owner = msg.sender;

    function WithdrawToken(
        address token,
        uint256 amount,
        address to
    ) public onlyOwner {
        bool __sent_result100 = token.call(
            bytes4(sha3("transfer(address,uint256)")),
            to,
            amount
        );
        require(__sent_result100);
    }
}

contract TokenBank is sGuardPlus, Token {
    uint256 public MinDeposit;
    mapping(address => uint256) public Holders;

    function initTokenBank() public {
        owner = msg.sender;
        MinDeposit = 1 ether;
    }

    function() payable {
        Deposit();
    }

    function Deposit() payable {
        if (msg.value > MinDeposit) {
            Holders[msg.sender] += msg.value;
        }
    }

    function WitdrawTokenToHolder(
        address _to,
        address _token,
        uint256 _amount
    ) public onlyOwner {
        if (Holders[_to] > 0) {
            Holders[_to] = 0;
            WithdrawToken(_token, _amount, _to);
        }
    }

    function WithdrawToHolder(address _addr, uint256 _wei)
        public
        payable
        onlyOwner
        __lock_modifier0
    {
        if (Holders[_addr] > 0) {
            if (_addr.call.value(_wei)()) {
                Holders[_addr] = sub_uint(Holders[_addr], _wei);
            }
        }
    }
}
