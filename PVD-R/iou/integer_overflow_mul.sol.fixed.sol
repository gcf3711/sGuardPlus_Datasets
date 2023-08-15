pragma solidity ^0.4.19;

contract sGuardPlus {
    constructor() internal {}

    function mul_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
}

contract IntegerOverflowMul is sGuardPlus {
    uint256 public count = 2;

    function run(uint256 input) public {
        count = mul_uint(count, input);
    }
}
