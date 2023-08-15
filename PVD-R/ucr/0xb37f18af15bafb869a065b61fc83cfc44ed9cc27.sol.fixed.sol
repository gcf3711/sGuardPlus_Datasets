pragma solidity ^0.4.24;

contract sGuardPlus {
    constructor() internal {}
}

contract SimpleWallet {
    address public owner = msg.sender;
    uint256 public depositsCount;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function withdrawAll() public onlyOwner {
        withdraw(address(this).balance);
    }

    function withdraw(uint256 _value) public onlyOwner {
        msg.sender.transfer(_value);
    }

    function sendMoney(address _target, uint256 _value) public onlyOwner {
        bool __sent_result100 = _target.call.value(_value)();
        require(__sent_result100);
    }
}
