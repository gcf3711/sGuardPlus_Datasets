pragma solidity ^0.4.13;

contract sGuardPlus {
    constructor() internal {}

    function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
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

    function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
}

contract owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _extraData
    );
}

contract token is sGuardPlus {
    string public standard = "Token 0.1";
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
    ) {
        balanceOf[msg.sender] = initialSupply;
        totalSupply = initialSupply;
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
    }

    function transfer(address _to, uint256 _value) {
        assert(balanceOf[msg.sender] >= _value);
        assert(add_uint256(balanceOf[_to], _value) >= balanceOf[_to]);
        balanceOf[msg.sender] = sub_uint256(balanceOf[msg.sender], _value);
        balanceOf[_to] = add_uint256(balanceOf[_to], _value);
        Transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes _extraData
    ) returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool success) {
        assert(balanceOf[_from] >= _value);
        assert(balanceOf[_to] + _value >= balanceOf[_to]);
        assert(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function() {
        assert(false);
    }
}

contract MyYLCToken is sGuardPlus, owned, token {
    uint256 public sellPrice;
    uint256 public buyPrice;
    mapping(address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    event Burn(address indexed from, uint256 value);

    constructor(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
    ) token(initialSupply, tokenName, decimalUnits, tokenSymbol) {}

    function transfer(address _to, uint256 _value) {
        assert(balanceOf[msg.sender] >= _value);
        assert(add_uint256(balanceOf[_to], _value) >= balanceOf[_to]);
        assert(!frozenAccount[msg.sender]);
        balanceOf[msg.sender] = sub_uint256(balanceOf[msg.sender], _value);
        balanceOf[_to] = add_uint256(balanceOf[_to], _value);
        Transfer(msg.sender, _to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool success) {
        assert(!frozenAccount[_from]);
        assert(balanceOf[_from] >= _value);
        assert(balanceOf[_to] + _value >= balanceOf[_to]);
        assert(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] = add_uint256(balanceOf[target], mintedAmount);
        totalSupply = add_uint256(totalSupply, mintedAmount);
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() payable {
        uint256 amount = msg.value / buyPrice;
        assert(balanceOf[this] >= amount);
        balanceOf[msg.sender] += amount;
        balanceOf[this] -= amount;
        Transfer(this, msg.sender, amount);
    }

    function sell(uint256 amount) {
        assert(balanceOf[msg.sender] >= amount);
        balanceOf[this] = add_uint256(balanceOf[this], amount);
        balanceOf[msg.sender] = sub_uint256(balanceOf[msg.sender], amount);
        if (!msg.sender.send(mul_uint256(amount, sellPrice))) {
        Transfer(msg.sender, this, amount);
    }

    function burn(uint256 amount) onlyOwner returns (bool success) {
        assert(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] = sub_uint256(balanceOf[msg.sender], amount);
        totalSupply = sub_uint256(totalSupply, amount);
        Burn(msg.sender, amount);
        return true;
    }
}
