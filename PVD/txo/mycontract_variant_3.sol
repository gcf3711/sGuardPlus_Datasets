/*
 * @source: https://consensys.github.io/smart-contract-best-practices/recommendations/#avoid-using-txorigin
 * @author: Consensys Diligence
 * @vulnerable_at_lines: 20
 * Modified by Gerhard Wagner
 */

pragma solidity ^0.4.24;

contract MyContract {

    address owner;

    function MyContract() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        // <yes> <report> ACCESS_CONTROL
        require(tx.origin == owner,"Not owner");
        _;
    }

    function sendTo(address receiver, uint amount) public onlyOwner{
        receiver.transfer(amount);
    }

}
