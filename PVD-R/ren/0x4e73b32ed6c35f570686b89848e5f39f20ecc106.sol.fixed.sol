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

contract PRIVATE_ETH_CELL is sGuardPlus {
    mapping(address => uint256) public balances;
    uint256 public MinSum;
    LogFile Log;
    bool intitalized;

    function SetMinSum(uint256 _val) public {
        require(!intitalized);
        MinSum = _val;
    }

    function SetLogFile(address _log) public {
        require(!intitalized);
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
