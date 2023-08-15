pragma solidity ^0.4.8;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
}

contract MP3Coin is sGuardPlus {
    string public constant symbol = "MP3";
    string public constant name = "MP3 Coin";
    string public constant slogan = "Make Music Great Again";
    uint256 public constant decimals = 8;
    uint256 public totalSupply = 1000000 * 10**decimals;
    address owner;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor() public {
        owner = msg.sender;
        balances[owner] = totalSupply;
        Transfer(this, owner, totalSupply);
    }

    function balanceOf(address _owner)
        public
        constant
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _amount)
        public
        returns (bool success)
    {
        require(_amount > 0 && balances[msg.sender] >= _amount);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        require(
            _amount > 0 &&
                balances[_from] >= _amount &&
                allowed[_from][msg.sender] >= _amount
        );
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount)
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function distribute(address[] _addresses, uint256[] _amounts)
        public
        returns (bool success)
    {
        require(
            _addresses.length < 256 && _addresses.length == _amounts.length
        );
        uint256 totalAmount;
        for (uint256 a = 0; a < _amounts.length; a = add_uint(a, 1)) {
            totalAmount = add_uint(totalAmount, _amounts[a]);
        }

        require(totalAmount > 0 && balances[msg.sender] >= totalAmount);
        balances[msg.sender] = sub_uint(balances[msg.sender], totalAmount);
        for (uint256 b = 0; b < _addresses.length; b = add_uint(b, 1)) {
            if (_amounts[b] > 0) {
                balances[_addresses[b]] = add_uint(
                    balances[_addresses[b]],
                    _amounts[b]
                );
                Transfer(msg.sender, _addresses[b], _amounts[b]);
            }
        }

        return true;
    }
}
