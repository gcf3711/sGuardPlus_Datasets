pragma solidity ^0.4.18;

contract sGuardPlus {
    constructor() internal {}

    function sub_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Token is sGuardPlus {
    mapping(address => uint256) balances;
    uint256 public totalSupply;

    constructor(uint256 _initialSupply) {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(sub_uint(balances[msg.sender], _value) >= 0);
        balances[msg.sender] = sub_uint(balances[msg.sender], _value);
        balances[_to] = add_uint(balances[_to], _value);
        return true;
    }

    function balanceOf(address _owner)
        public
        constant
        returns (uint256 balance)
    {
        return balances[_owner];
    }
}
