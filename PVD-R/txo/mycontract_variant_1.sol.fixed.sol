pragma solidity ^0.4.24;

contract sGuardPlus {
    constructor() internal {}
}

contract MyContract {
    address variantAddress;

    constructor() public {
        variantAddress = msg.sender;
    }

    function variantSendTo(address receiver, uint amount) public {
        require(msg.sender == variantAddress);
        receiver.transfer(amount);
    }
}
