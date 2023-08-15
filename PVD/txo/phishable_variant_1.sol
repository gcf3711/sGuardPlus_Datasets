/*
 * @source: https://github.com/sigp/solidity-security-blog
 * @author: -
 * @vulnerable_at_lines: 20
 */

 pragma solidity ^0.4.22;

 contract Phishable {
    address public variantAddress;

    constructor (address _owner) {
        variantAddress = _owner;
    }

    function () public payable {} // collect ether

    function variantWithdrawAll(address _recipient) public {
        // <yes> <report> ACCESS_CONTROL
        require(tx.origin == variantAddress);
        _recipient.transfer(this.balance);
    }
}
