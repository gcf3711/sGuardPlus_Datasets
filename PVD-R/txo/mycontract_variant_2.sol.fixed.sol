pragma solidity ^0.4.24;

contract sGuardPlus {
    constructor() internal {}
}

contract MyContract {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        if (msg.sender == owner) {
            receiver.transfer(amount);
        }
    }
}
