pragma solidity ^0.4.19;

contract sGuardPlus {
    constructor() internal {}

    function sub_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
}

contract IntegerOverflowMinimal is sGuardPlus {
    uint256 public count = 1;

    function run(uint256 input) public {
        count = sub_uint(count, input);
    }
}
