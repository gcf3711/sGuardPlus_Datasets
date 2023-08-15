pragma solidity ^0.4.21;

contract sGuardPlus {
    constructor() internal {}

    function mul_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC223ReceivingContract {
    function tokenFallback(
        address _from,
        uint256 _value,
        bytes _data
    ) public;
}

contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public;

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
        public
        constant
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public;

    function approve(address spender, uint256 value) public;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract BasicToken is sGuardPlus, ERC20Basic {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    modifier onlyPayloadSize(uint256 size) {
        require(msg.data.length >= size + 4);
        _;
    }

    function transfer(address _to, uint256 _value)
        public
        onlyPayloadSize(mul_uint256(2, 32))
    {
        uint256 codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }

        emit Transfer(msg.sender, _to, _value);
    }

    function balanceOf(address _owner)
        public
        constant
        returns (uint256 balance)
    {
        return balances[_owner];
    }
}

contract StandardToken is BasicToken, ERC20 {
    mapping(address => mapping(address => uint256)) allowed;

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public {
        uint256 _allowance = allowed[_from][msg.sender];
        uint256 codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }

        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }
}

contract BurnableToken is StandardToken {
    function burn(uint256 _value) public {
        require(_value > 0);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }

    event Burn(address indexed burner, uint256 indexed value);
}

contract ETY is sGuardPlus, BurnableToken {
    string public name = "Etherty Token";
    string public symbol = "ETY";
    uint256 public decimals = 18;
    uint256 constant TOKEN_LIMIT = 240 * 1e6 * 1e18;
    address public ico;
    bool public tokensAreFrozen = true;

    constructor(address _ico) public {
        ico = _ico;
    }

    function mint(address _holder, uint256 _value) external {
        require(msg.sender == ico);
        require(_value != 0);
        require(add_uint(totalSupply, _value) <= TOKEN_LIMIT);
        balances[_holder] = add_uint(balances[_holder], _value);
        totalSupply = add_uint(totalSupply, _value);
        emit Transfer(0x0, _holder, _value);
    }

    function burn(uint256 _value) public {
        require(msg.sender == ico);
        super.burn(_value);
    }

    function unfreeze() external {
        require(msg.sender == ico);
        tokensAreFrozen = false;
    }

    function transfer(address _to, uint256 _value) public {
        require(!tokensAreFrozen);
        super.transfer(_to, _value);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public onlyPayloadSize(mul_uint256(3, 32)) {
        require(!tokensAreFrozen);
        super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public {
        require(!tokensAreFrozen);
        super.approve(_spender, _value);
    }
}
