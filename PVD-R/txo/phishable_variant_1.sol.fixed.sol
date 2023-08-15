pragma solidity ^0.4.22;

contract sGuardPlus {
    constructor() internal {}
}

contract Phishable {
    address public variantAddress;

    constructor(address _owner) {
        variantAddress = _owner;
    }

    function() public payable {}

    function variantWithdrawAll(address _recipient) public {
        require(msg.sender == variantAddress);
        _recipient.transfer(this.balance);
    }
}
