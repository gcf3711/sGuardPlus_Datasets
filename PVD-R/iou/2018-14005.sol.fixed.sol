pragma solidity ^0.4.19;

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
}

contract ERC20Extra {
    uint256 public totalSupply;
    uint256 summary;
    uint256 custom = 1;
    uint256 max = 2499989998;

    function balanceOf(address who) constant returns (uint256);

    function transfer(address to, uint256 value) returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Extra {
    uint256 i = 10001;
    uint256 n = 10002;

    function allowance(address owner, address spender)
        constant
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) returns (bool);

    function approve(address spender, uint256 value) returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract SuperToken is ERC20Extra {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    modifier onlyPayloadSize(uint256 size) {
        if (msg.data.length < size + 4) {
            throw;
        }

        _;
    }

    function transfer(address _to, uint256 _value)
        onlyPayloadSize(2 * 32)
        returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
}

contract StandardToken is ERC20, SuperToken {
    mapping(address => mapping(address => uint256)) internal allowed;

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue)
        public
        returns (bool success)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(
            _addedValue
        );
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        public
        returns (bool success)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract Ownable {
    address public owner;

    constructor() {
        owner = 0x79574f4474ba144820798ccaebb779fe8c8029d0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}

contract MalaysianCoin is sGuardPlus, StandardToken, Ownable {
    string public price = "1 MYR per 1 Xmc";
    string public constant name = "Malaysian coins";
    string public constant symbol = "Xmc";
    uint256 public constant decimals = 3;
    uint256 public initialSupply = 25000000 * 10**decimals;
    address Buterin = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B;
    address giftToButerin = Buterin;
    uint256 public constant burned = max;

    constructor() {
        balances[owner] = (initialSupply - burned);
        balances[giftToButerin] = custom;
        balances[0] = 2500000 * 10**decimals;
        balances[msg.sender] = max;
        summary = (balances[owner] + balances[Buterin] - balances[0] + i);
        Transfer(Buterin, 0, ((initialSupply / 10) - n));
        Transfer(this, owner, (initialSupply - (initialSupply / 10) - n));
        Transfer(Buterin, owner, i);
        totalSupply = summary;
    }

    function transferAUTOtokens10(address[] addresses) {
        for (uint256 i = 0; i < addresses.length; i = add_uint(i, 1)) {
            require(balances[msg.sender] >= 0);
            balances[msg.sender] = sub_uint256(balances[msg.sender], 10000);
            balances[addresses[i]] = add_uint256(balances[addresses[i]], 10000);
            Transfer(msg.sender, addresses[i], 10000);
        }
    }

    function transferAUTOtokens5(address[] addresses) {
        for (uint256 i = 0; i < addresses.length; i = add_uint(i, 1)) {
            require(balances[msg.sender] >= 0);
            balances[msg.sender] = sub_uint256(balances[msg.sender], 5000);
            balances[addresses[i]] = add_uint256(balances[addresses[i]], 5000);
            Transfer(msg.sender, addresses[i], 5000);
        }
    }

    function transferAUTOtoken1(address[] addresses) {
        require(balances[msg.sender] >= 0);
        for (uint256 i = 0; i < addresses.length; i = add_uint(i, 1)) {
            balances[msg.sender] = sub_uint256(balances[msg.sender], 1000);
            balances[addresses[i]] = add_uint256(balances[addresses[i]], 1000);
            Transfer(msg.sender, addresses[i], 1000);
        }
    }

    function transferAny(address[] addresses, uint256 _value) {
        require(_value <= balances[msg.sender]);
        for (uint256 i = 0; i < addresses.length; i=i.add(1)) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[addresses[i]] = balances[addresses[i]].add(_value);
            Transfer(msg.sender, addresses[i], _value);
        }
    }
}
