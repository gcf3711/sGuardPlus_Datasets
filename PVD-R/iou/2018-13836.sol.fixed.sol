pragma solidity ^0.4.18;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mul_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function mul_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function pow_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = 1;
        for (uint256 i = 0; i < b; i = add_uint256(i, 1)) {
            c = mul_uint256(c, a);
        }
        return c;
    }
}

contract Token {
    function balanceOf(address _account)
        public
        constant
        returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        public
        returns (bool success);
}

contract RocketCoin is sGuardPlus {
    string public constant symbol = "XRC";
    string public constant name = "Rocket Coin";
    uint256 public constant decimals = 18;
    uint256 public constant totalSupply = 10000000 * 10**decimals;
    address owner;
    bool airDropStatus = true;
    uint256 airDropAmount = 300 * 10**decimals;
    uint256 airDropGasPrice = 20 * 10**9;
    mapping(address => bool) participants;
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
        Transfer(address(0), owner, totalSupply);
    }

    function() public payable {
        require(
            airDropStatus &&
                balances[owner] >= airDropAmount &&
                !participants[msg.sender] &&
                tx.gasprice >= airDropGasPrice
        );
        balances[owner] -= airDropAmount;
        balances[msg.sender] += airDropAmount;
        Transfer(owner, msg.sender, airDropAmount);
        participants[msg.sender] = true;
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
        require(balances[msg.sender] >= _amount && _amount > 0);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function multiTransfer(address[] _addresses, uint256[] _amounts)
        public
        returns (bool success)
    {
        require(
            _addresses.length <= 100 && _addresses.length == _amounts.length
        );
        uint256 totalAmount;
        for (uint256 a = 0; a < _amounts.length; a = add_uint(a, 1)) {
            totalAmount = add_uint(totalAmount, _amounts[a]);
        }

        require(totalAmount > 0 && balances[msg.sender] >= totalAmount);
        balances[msg.sender] = sub_uint256(balances[msg.sender], totalAmount);
        for (uint256 b = 0; b < _addresses.length; b = add_uint(b, 1)) {
            if (_amounts[b] > 0) {
                balances[_addresses[b]] = add_uint256(
                    balances[_addresses[b]],
                    _amounts[b]
                );
                Transfer(msg.sender, _addresses[b], _amounts[b]);
            }
        }

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        require(
            balances[_from] >= _amount &&
                allowed[_from][msg.sender] >= _amount &&
                _amount > 0
        );
        balances[_from] = sub_uint256(balances[_from], _amount);
        allowed[_from][msg.sender] = sub_uint256(
            allowed[_from][msg.sender],
            _amount
        );
        balances[_to] = add_uint256(balances[_to], _amount);
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

    function setupAirDrop(
        bool _status,
        uint256 _amount,
        uint256 _Gwei
    ) public returns (bool success) {
        require(msg.sender == owner);
        airDropStatus = _status;
        airDropAmount = mul_uint(_amount, pow_uint256(10, decimals));
        airDropGasPrice = mul_uint(_Gwei, pow_uint256(10, 9));
        return true;
    }

    function withdrawFunds(address _token) public returns (bool success) {
        require(msg.sender == owner);
        if (_token == address(0)) {
            owner.transfer(this.balance);
        } else {
            Token ERC20 = Token(_token);
            bool __sent_result101 = ERC20.transfer(
                owner,
                ERC20.balanceOf(this)
            );
            require(__sent_result101);
        }

        return true;
    }
}
