pragma solidity ^0.4.23;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mul_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function sub_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
}

contract IntegerOverflowSingleTransaction is sGuardPlus {
    uint256 public count = 1;

    function overflowaddtostate(uint256 input) public {
        count = add_uint(count, input);
    }

    function overflowmultostate(uint256 input) public {
        count = mul_uint(count, input);
    }

    function underflowtostate(uint256 input) public {
        count = sub_uint(count, input);
    }

    function overflowlocalonly(uint256 input) public {
        uint256 res = add_uint(count, input);
    }

    function overflowmulocalonly(uint256 input) public {
        uint256 res = mul_uint(count, input);
    }

    function underflowlocalonly(uint256 input) public {
        uint256 res = sub_uint(count, input);
    }
}
