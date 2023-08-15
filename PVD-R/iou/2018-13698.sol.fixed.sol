pragma solidity ^0.4.18;

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

contract Play2LivePromo is sGuardPlus {
    address public owner;
    string public constant name = "Level Up Coin Diamond | play2live.io";
    string public constant symbol = "LUCD";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 0;
    uint256 promoValue = 777 * 1e18;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    event Transfer(address _from, address _to, uint256 amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setPromo(uint256 _newValue) external onlyOwner {
        promoValue = _newValue;
    }

    function balanceOf(address _investor) public constant returns (uint256) {
        return balances[_investor];
    }

    function mintTokens(address _investor) external onlyOwner {
        balances[_investor] = add_uint(balances[_investor], promoValue);
        totalSupply = add_uint(totalSupply, promoValue);
        Transfer(0x0, _investor, promoValue);
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        balances[msg.sender] = sub_uint(balances[msg.sender], _amount);
        balances[_to] = sub_uint(balances[_to], _amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        balances[_from] = sub_uint(balances[_from], _amount);
        allowed[_from][msg.sender] = sub_uint(
            allowed[_from][msg.sender],
            _amount
        );
        balances[_to] = sub_uint(balances[_to], _amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender)
        constant
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }
}
