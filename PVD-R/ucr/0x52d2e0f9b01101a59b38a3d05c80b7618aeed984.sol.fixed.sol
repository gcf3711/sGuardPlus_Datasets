pragma solidity ^0.4.19;

contract sGuardPlus {
    constructor() internal {}
}

contract Token {
    function transfer(address _to, uint256 _value) returns (bool success);

    function balanceOf(address _owner) constant returns (uint256 balance);
}

contract EtherGet {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function withdrawTokens(address tokenContract) public {
        Token tc = Token(tokenContract);
        bool __sent_result100 = tc.transfer(owner, tc.balanceOf(this));
        require(__sent_result100);
    }

    function withdrawEther() public {
        owner.transfer(this.balance);
    }

    function getTokens(uint256 num, address addr) public {
        for (uint256 i = 0; i < num; i++) {
            bool __sent_result102 = addr.call.value(0 wei)();
            require(__sent_result102);
        }
    }
}
