pragma solidity ^0.4.19;

contract sGuardPlus {
    constructor() internal {
        __lock_modifier0_lock = false;
    }

    bool private __lock_modifier0_lock;
    modifier __lock_modifier0() {
        require(!__lock_modifier0_lock);
        __lock_modifier0_lock = true;
        _;
        __lock_modifier0_lock = false;
    }
}

contract PERSONAL_BANK is sGuardPlus {
    mapping(address => uint256) public balances;
    uint256 public MinSum = 1 ether;
    LogFile Log = LogFile(0x0486cF65A2F2F3A392CBEa398AFB7F5f0B72FF46);
    bool intitalized;

    function SetMinSum(uint256 _val) public {
        if (intitalized) revert();

        MinSum = _val;
    }

    function SetLogFile(address _log) public {
        if (intitalized) revert();

        Log = LogFile(_log);
    }

    function Initialized() public {
        intitalized = true;
    }

    function Deposit() public payable {
        balances[msg.sender] += msg.value;
        Log.AddMessage(msg.sender, msg.value, "Put");
    }

    function Collect(uint256 _am) public payable __lock_modifier0 {
        if (balances[msg.sender] >= MinSum && balances[msg.sender] >= _am) {
            if (msg.sender.call.value(_am)()) {
                balances[msg.sender] -= _am;
                Log.AddMessage(msg.sender, _am, "Collect");
            }
        }
    }

    function() public payable {
        Deposit();
    }
}

contract LogFile {
    struct Message {
        address Sender;
        string Data;
        uint256 Val;
        uint256 Time;
    }
    Message[] public History;
    Message LastMsg;

    function AddMessage(
        address _adr,
        uint256 _val,
        string _data
    ) public {
        LastMsg.Sender = _adr;
        LastMsg.Time = now;
        LastMsg.Val = _val;
        LastMsg.Data = _data;
        History.push(LastMsg);
    }
}
