pragma solidity ^0.4.9;

contract sGuardPlus {
    constructor() internal {
        __lock_modifier0_lock = false;
    }

    function mul_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function sub_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    bool private __lock_modifier0_lock;
    modifier __lock_modifier0() {
        require(!__lock_modifier0_lock);
        __lock_modifier0_lock = true;
        _;
        __lock_modifier0_lock = false;
    }
}

contract TownCrier is sGuardPlus {
    struct Request {
        address requester;
        uint256 fee;
        address callbackAddr;
        bytes4 callbackFID;
        bytes32 paramsHash;
    }
    event Upgrade(address newAddr);
    event Reset(uint256 gas_price, uint256 min_fee, uint256 cancellation_fee);
    event RequestInfo(
        uint64 id,
        uint8 requestType,
        address requester,
        uint256 fee,
        address callbackAddr,
        bytes32 paramsHash,
        uint256 timestamp,
        bytes32[] requestData
    );
    event DeliverInfo(
        uint64 requestId,
        uint256 fee,
        uint256 gasPrice,
        uint256 gasLeft,
        uint256 callbackGas,
        bytes32 paramsHash,
        uint64 error,
        bytes32 respData
    );
    event Cancel(
        uint64 requestId,
        address canceller,
        address requester,
        uint256 fee,
        int256 flag
    );
    address public constant SGX_ADDRESS =
        0x18513702cCd928F2A3eb63d900aDf03c9cc81593;
    uint256 public GAS_PRICE = 5 * 10**10;
    uint256 public MIN_FEE = 30000 * GAS_PRICE;
    uint256 public CANCELLATION_FEE = 25000 * GAS_PRICE;
    uint256 public constant CANCELLED_FEE_FLAG = 1;
    uint256 public constant DELIVERED_FEE_FLAG = 0;
    int256 public constant FAIL_FLAG = -2**250;
    int256 public constant SUCCESS_FLAG = 1;
    bool public killswitch;
    bool public externalCallFlag;
    uint64 public requestCnt;
    uint64 public unrespondedCnt;
    Request[2**64] public requests;
    int256 public newVersion = 0;

    function() {}

    constructor() public {
        requestCnt = 1;
        requests[0].requester = msg.sender;
        killswitch = false;
        unrespondedCnt = 0;
        externalCallFlag = false;
    }

    function upgrade(address newAddr) {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            newVersion = -int256(newAddr);
            killswitch = true;
            Upgrade(newAddr);
        }
    }

    function reset(
        uint256 price,
        uint256 minGas,
        uint256 cancellationGas
    ) public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            GAS_PRICE = price;
            MIN_FEE = mul_uint(price, minGas);
            CANCELLATION_FEE = mul_uint(price, cancellationGas);
            Reset(GAS_PRICE, MIN_FEE, CANCELLATION_FEE);
        }
    }

    function suspend() public {
        if (msg.sender == requests[0].requester) {
            killswitch = true;
        }
    }

    function restart() public {
        if (msg.sender == requests[0].requester && newVersion == 0) {
            killswitch = false;
        }
    }

    function withdraw() public {
        if (msg.sender == requests[0].requester && unrespondedCnt == 0) {
            if (!requests[0].requester.call.value(this.balance)()) {
                throw;
            }
        }
    }

    function request(
        uint8 requestType,
        address callbackAddr,
        bytes4 callbackFID,
        uint256 timestamp,
        bytes32[] requestData
    ) public payable returns (int256) {
        if (externalCallFlag) {
            throw;
        }

        if (killswitch) {
            externalCallFlag = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }

            externalCallFlag = false;
            return newVersion;
        }

        if (msg.value < MIN_FEE) {
            externalCallFlag = true;
            if (!msg.sender.call.value(msg.value)()) {
                throw;
            }

            externalCallFlag = false;
            return FAIL_FLAG;
        } else {
            uint64 requestId = requestCnt;
            requestCnt++;
            unrespondedCnt++;
            bytes32 paramsHash = sha3(requestType, requestData);
            requests[requestId].requester = msg.sender;
            requests[requestId].fee = msg.value;
            requests[requestId].callbackAddr = callbackAddr;
            requests[requestId].callbackFID = callbackFID;
            requests[requestId].paramsHash = paramsHash;
            RequestInfo(
                requestId,
                requestType,
                msg.sender,
                msg.value,
                callbackAddr,
                paramsHash,
                timestamp,
                requestData
            );
            return requestId;
        }
    }

    function deliver(
        uint64 requestId,
        bytes32 paramsHash,
        uint64 error,
        bytes32 respData
    ) public __lock_modifier0 {
        if (
            msg.sender != SGX_ADDRESS ||
            requestId <= 0 ||
            requests[requestId].requester == 0 ||
            requests[requestId].fee == DELIVERED_FEE_FLAG
        ) {
            return;
        }

        uint256 fee = requests[requestId].fee;
        if (requests[requestId].paramsHash != paramsHash) {
            return;
        } else if (fee == CANCELLED_FEE_FLAG) {
            bool __sent_result104 = SGX_ADDRESS.send(CANCELLATION_FEE);
            require(__sent_result104);
            requests[requestId].fee = DELIVERED_FEE_FLAG;
            unrespondedCnt--;
            return;
        }

        requests[requestId].fee = DELIVERED_FEE_FLAG;
        unrespondedCnt--;
        if (error < 2) {
            bool __sent_result105 = SGX_ADDRESS.send(fee);
            require(__sent_result105);
        } else {
            externalCallFlag = true;
            bool __sent_result106 = requests[requestId]
                .requester
                .call
                .gas(2300)
                .value(fee)();
            require(__sent_result106);
            externalCallFlag = false;
        }

        uint256 callbackGas = (fee - MIN_FEE) / tx.gasprice;
        DeliverInfo(
            requestId,
            fee,
            tx.gasprice,
            msg.gas,
            callbackGas,
            paramsHash,
            error,
            respData
        );
        if (callbackGas > msg.gas - 5000) {
            callbackGas = msg.gas - 5000;
        }

        externalCallFlag = true;
        bool __sent_result103 = requests[requestId].callbackAddr.call.gas(
            callbackGas
        )(requests[requestId].callbackFID, requestId, error, respData);
        require(__sent_result103);
        externalCallFlag = false;
    }

    function cancel(uint64 requestId) public returns (int256) {
        if (externalCallFlag) {
            throw;
        }

        if (killswitch) {
            return 0;
        }

        uint256 fee = requests[requestId].fee;
        if (
            requests[requestId].requester == msg.sender &&
            fee >= CANCELLATION_FEE
        ) {
            requests[requestId].fee = CANCELLED_FEE_FLAG;
            externalCallFlag = true;
            if (!msg.sender.call.value(sub_uint(fee, CANCELLATION_FEE))()) {
                throw;
            }

            externalCallFlag = false;
            Cancel(
                requestId,
                msg.sender,
                requests[requestId].requester,
                requests[requestId].fee,
                1
            );
            return SUCCESS_FLAG;
        } else {
            Cancel(
                requestId,
                msg.sender,
                requests[requestId].requester,
                fee,
                -1
            );
            return FAIL_FLAG;
        }
    }
}
