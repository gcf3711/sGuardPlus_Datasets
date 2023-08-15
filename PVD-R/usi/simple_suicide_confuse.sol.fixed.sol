pragma solidity ^0.4.22;

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

contract Ox6db76112322925f48328ca3c3c1e5e5b50472857 is sGuardPlus {
    function Ox6c6be552d755b34fe8c36483e9a25e4afd353244() __onlyOwner {
        selfdestruct(msg.sender);
    }
}
