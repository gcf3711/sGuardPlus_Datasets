pragma solidity ^0.4.16;

contract sGuardPlus {
    constructor() internal {
        __owner = msg.sender;
    }

    function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function mul_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = 1;
        for (uint256 i = 0; i < b; i = add_uint256(i, 1)) {
            c = mul_uint256(c, a);
        }
        return c;
    }

    address private __owner;
    modifier __onlyOwner() {
        require(msg.sender == __owner);
        _;
    }
}

interface tokenRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes _extraData
    ) external;
}

contract SafeM {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract TokenERC20 is sGuardPlus, SafeM {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    constructor() public {
        totalSupply = 90000000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = "Lehman Brothers Coin";
        symbol = "LBC";
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function Airdrop(address[] recipients, uint[] amount) {
        for (uint i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amount[i]);
        }
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value * 10 ** 18);
    }

    function destroycontract(address _to) __onlyOwner {
        selfdestruct(_to);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes _extraData
    ) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] = sub_uint256(balanceOf[msg.sender], _value);
        totalSupply = sub_uint256(totalSupply, _value);
        emit Burn(msg.sender, mul_uint256(_value, pow_uint256(10, 18)));
        return true;
    }

    function burnFrom(
        address _from,
        uint256 _value
    ) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value * 10 ** 18);
        return true;
    }

    function() public payable {
        uint tokens;
        tokens = msg.value * 300000;
        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], tokens);
        totalSupply = safeAdd(totalSupply, tokens);
        emit Transfer(address(0), msg.sender, tokens);
        msg.sender.transfer(msg.value);
    }
}
