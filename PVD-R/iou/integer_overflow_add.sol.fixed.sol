pragma solidity ^0.4.19;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract IntegerOverflowAdd is sGuardPlus {
    uint256 public count = 1;

    function run(uint256 input) public {
        count = add_uint(count, input);
    }
}
