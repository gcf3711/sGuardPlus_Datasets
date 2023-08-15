pragma solidity ^0.4.24;

contract sGuardPlus {
    constructor() internal {}
}

contract MyContract {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function sendTo(address receiver, uint amount) public onlyOwner {
        receiver.transfer(amount);
    }
}
