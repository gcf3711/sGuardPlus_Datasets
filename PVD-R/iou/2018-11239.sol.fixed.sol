pragma solidity ^0.4.18;

contract sGuardPlus {
    constructor() internal {}

    function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Hexagon is sGuardPlus {
    string public constant name = "Hexagon";
    string public constant symbol = "HXG";
    uint8 public constant decimals = 4;
    uint8 public constant burnPerTransaction = 2;
    uint256 public constant initialSupply = 420000000000000;
    uint256 public currentSupply = initialSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public {
        balanceOf[msg.sender] = initialSupply;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function totalSupply() public constant returns (uint256) {
        return currentSupply;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = sub_uint256(balanceOf[msg.sender], _value);
        balanceOf[0x0] = add_uint256(balanceOf[0x0], _value);
        currentSupply = sub_uint256(currentSupply, _value);
        Burn(msg.sender, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= add_uint256(_value, burnPerTransaction));
        require(add_uint256(balanceOf[_to] , _value) > balanceOf[_to]);
        balanceOf[_from] = sub_uint256(balanceOf[_from] , add_uint256(_value , burnPerTransaction));
        balanceOf[_to] = add_uint256(balanceOf[_to], _value);
        balanceOf[0x0] = add_uint256(balanceOf[0x0], burnPerTransaction);
        currentSupply = sub_uint256(currentSupply, burnPerTransaction);
        Burn(_from, burnPerTransaction);
        Transfer(_from, _to, _value);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}
