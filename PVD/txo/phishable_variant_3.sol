/*
 * @source: https://github.com/sigp/solidity-security-blog
 * @author: -
 * @vulnerable_at_lines: 20
 */

 pragma solidity ^0.4.22;

 contract Phishable {
    address public owner;

    constructor (address _owner) {
        owner = _owner;
    }

    function () public payable {} // collect ether

    modifier onlyOwner() {
        // <yes> <report> ACCESS_CONTROL
        require(tx.origin == owner,"Not owner");
        _;
    }

    function withdrawAll(address _recipient) public onlyOwner{
        _recipient.transfer(this.balance);
    }
}
