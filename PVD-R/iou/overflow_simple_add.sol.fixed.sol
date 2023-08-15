pragma solidity 0.4.26;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Overflow_Add is sGuardPlus {
    uint256 public balance = 1;

    function add(uint256 deposit) public {
        balance = add_uint(balance, deposit);
    }
}
