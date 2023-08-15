pragma solidity ^0.4.0;

contract sGuardPlus {
    constructor() internal {
        __lock_modifier0_lock = false;
    }

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    bool private __lock_modifier0_lock;
    modifier __lock_modifier0() {
        require(!__lock_modifier0_lock);
        __lock_modifier0_lock = true;
        _;
        __lock_modifier0_lock = false;
    }
}

contract Reentrancy_bonus is sGuardPlus {
    mapping(address => uint256) private userBalances;
    mapping(address => bool) private claimedBonus;
    mapping(address => uint256) private rewardsForA;

    function withdrawReward(address recipient) public {
        uint256 amountToWithdraw = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToWithdraw)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient)
        public
        __lock_modifier0
    {
        require(!claimedBonus[recipient]);
        rewardsForA[recipient] = add_uint(rewardsForA[recipient], 100);
        withdrawReward(recipient);
        claimedBonus[recipient] = true;
    }
}
