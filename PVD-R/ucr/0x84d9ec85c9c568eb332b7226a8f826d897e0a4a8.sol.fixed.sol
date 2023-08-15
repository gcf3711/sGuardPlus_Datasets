pragma solidity ^0.4.16;

contract sGuardPlus {
    constructor() internal {}
}

contract Owned {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    address public newOwner;

    function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }

    function execute(
        address _dst,
        uint256 _value,
        bytes _data
    ) onlyOwner {
        bool __sent_result100 = _dst.call.value(_value)(_data);
        require(__sent_result100);
    }
}

contract WedIndex is Owned {
    string public wedaddress;
    string public partnernames;
    uint256 public indexdate;
    uint256 public weddingdate;
    uint256 public displaymultisig;
    IndexArray[] public indexarray;
    struct IndexArray {
        uint256 indexdate;
        string wedaddress;
        string partnernames;
        uint256 weddingdate;
        uint256 displaymultisig;
    }

    function numberOfIndex() public constant returns (uint256) {
        return indexarray.length;
    }

    function writeIndex(
        uint256 indexdate,
        string wedaddress,
        string partnernames,
        uint256 weddingdate,
        uint256 displaymultisig
    ) {
        indexarray.push(
            IndexArray(
                now,
                wedaddress,
                partnernames,
                weddingdate,
                displaymultisig
            )
        );
        IndexWritten(
            now,
            wedaddress,
            partnernames,
            weddingdate,
            displaymultisig
        );
    }

    event IndexWritten(
        uint256 time,
        string contractaddress,
        string partners,
        uint256 weddingdate,
        uint256 display
    );
}
