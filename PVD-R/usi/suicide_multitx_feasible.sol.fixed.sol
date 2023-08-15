/* @Labeled: [17] */
pragma solidity ^0.4.23;
contract sGuardPlus {
    constructor() internal {
        __owner = msg.sender;
    }

    address private __owner;
    modifier __onlyOwner() {
        require(msg.sender == __owner);
        _;
    }
}

contract SuicideMultiTxFeasible is sGuardPlus {
    uint256 private initialized = 0;
    uint256 public count = 1;

    function init() public {
        initialized = 1;
    }

    function run(uint256 input) __onlyOwner{
        if (initialized == 0) {
            return;
        }

        selfdestruct(msg.sender);
    }
}
