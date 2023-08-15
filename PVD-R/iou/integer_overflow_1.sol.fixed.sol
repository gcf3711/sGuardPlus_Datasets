/*
 * @source: https://github.com/trailofbits/not-so-smart-contracts/blob/master/integer_overflow/integer_overflow_1.sol
 * @author: -
 * @vulnerable_at_lines: 14
 */

pragma solidity ^0.4.15;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Overflow is sGuardPlus {
    uint256 private sellerBalance = 0;

    function add(uint256 value) returns (bool) {
        // <yes> <report> ARITHMETIC
        sellerBalance = add_uint(sellerBalance, value); // possible overflow

        // possible auditor assert
        // assert(sellerBalance >= value);
    }

    // function safe_add(uint value) returns (bool){
    //   require(value + sellerBalance >= sellerBalance);
    // sellerBalance += value;
    // }
}
