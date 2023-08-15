/*
 * @source: https://consensys.github.io/smart-contract-best-practices/recommendations/#avoid-using-txorigin
 * @author: Consensys Diligence
 * @vulnerable_at_lines: 20
 * Modified by Gerhard Wagner
 */

pragma solidity ^0.4.24;

contract MyContract {

    address variantAddress;

    function MyContract() public {
        variantAddress = msg.sender;
    }

    function variantSendTo(address receiver, uint amount) public {
        // <yes> <report> ACCESS_CONTROL
        require(tx.origin == variantAddress);
        receiver.transfer(amount);
    }

}
