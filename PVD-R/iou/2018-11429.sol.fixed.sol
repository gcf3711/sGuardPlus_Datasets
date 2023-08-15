pragma solidity ^0.4.11;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + (a % b));
        return c;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }

    function assert(bool assertion) internal {
        if (!assertion) {
            throw;
        }
    }
}

contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) constant returns (uint256);

    function transfer(address to, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
        constant
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    );

    function approve(address spender, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    modifier onlyPayloadSize(uint256 size) {
        if (msg.data.length < size + 4) {
            throw;
        }

        _;
    }

    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
}

contract StandardToken is BasicToken, ERC20 {
    mapping(address => mapping(address => uint256)) allowed;

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) {
        var _allowance = allowed[_from][msg.sender];
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender)
        constant
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }
}

contract ATL is sGuardPlus, StandardToken {
    string public name = "ATLANT Token";
    string public symbol = "ATL";
    uint256 public decimals = 18;
    uint256 constant TOKEN_LIMIT = 150 * 1e6 * 1e18;
    address public ico;
    bool public tokensAreFrozen = true;

    constructor(address _ico) {
        ico = _ico;
    }

    function mint(address _holder, uint256 _value) external {
        require(msg.sender == ico);
        require(_value != 0);
        require(add_uint(totalSupply, _value) <= TOKEN_LIMIT);
        balances[_holder] = add_uint(balances[_holder], _value);
        totalSupply = add_uint(totalSupply, _value);
        Transfer(0x0, _holder, _value);
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
    ) public {
        require(!tokensAreFrozen);
        super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public {
        require(!tokensAreFrozen);
        super.approve(_spender, _value);
    }
}
