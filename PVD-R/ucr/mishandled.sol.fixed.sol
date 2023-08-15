pragma solidity ^0.4.0;

contract sGuardPlus {
    constructor() internal {}
}

contract SendBack {
    mapping(address => uint256) userBalances;

    function withdrawBalance() {
        uint256 amountToWithdraw = userBalances[msg.sender];
        userBalances[msg.sender] = 0;
        bool __sent_result100 = msg.sender.send(amountToWithdraw);
        require(__sent_result100);
    }
}
