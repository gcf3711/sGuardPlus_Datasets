pragma solidity ^0.4.22;

contract sGuardPlus {
    constructor() internal {}
}

contract Phishable {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function() public payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function withdrawAll(address _recipient) public onlyOwner {
        _recipient.transfer(this.balance);
    }
}
