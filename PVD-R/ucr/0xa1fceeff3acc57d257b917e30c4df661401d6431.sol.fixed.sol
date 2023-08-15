pragma solidity ^0.4.18;

contract sGuardPlus {
    constructor() internal {}
}

contract AirDropContract {
    constructor() public {}

    modifier validAddress(address addr) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function transfer(
        address contract_address,
        address[] tos,
        uint256[] vs
    ) public validAddress(contract_address) returns (bool) {
        require(tos.length > 0);
        require(vs.length > 0);
        require(tos.length == vs.length);
        bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for (uint256 i = 0; i < tos.length; i++) {
            bool __sent_result101 = contract_address.call(
                id,
                msg.sender,
                tos[i],
                vs[i]
            );
            require(__sent_result101);
        }

        return true;
    }
}
