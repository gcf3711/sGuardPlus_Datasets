pragma solidity ^0.4.0;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract demo is sGuardPlus {
    function transfer(
        address from,
        address caddress,
        address[] _tos,
        uint256[] v
    ) public returns (bool) {
        require(_tos.length > 0);
        bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for (uint256 i = 0; i < _tos.length; i = add_uint(i, 1)) {
            bool __sent_result101 = caddress.call(id, from, _tos[i], v[i]);
            require(__sent_result101);
        }

        return true;
    }
}
