pragma solidity ^0.4.0;

contract sGuardPlus {
    constructor() internal {}
}

contract KingOfTheEtherThrone {
    struct Monarch {
        address etherAddress;
        string name;
        uint256 claimPrice;
        uint256 coronationTimestamp;
    }
    address wizardAddress;
    modifier onlywizard() {
        if (msg.sender == wizardAddress) _;
    }
    uint256 constant startingClaimPrice = 100 finney;
    uint256 constant claimPriceAdjustNum = 3;
    uint256 constant claimPriceAdjustDen = 2;
    uint256 constant wizardCommissionFractionNum = 1;
    uint256 constant wizardCommissionFractionDen = 100;
    uint256 public currentClaimPrice;
    Monarch public currentMonarch;
    Monarch[] public pastMonarchs;

    constructor() {
        wizardAddress = msg.sender;
        currentClaimPrice = startingClaimPrice;
        currentMonarch = Monarch(wizardAddress, "[Vacant]", 0, block.timestamp);
    }

    function numberOfMonarchs() constant returns (uint256 n) {
        return pastMonarchs.length;
    }

    event ThroneClaimed(
        address usurperEtherAddress,
        string usurperName,
        uint256 newClaimPrice
    );

    function() {
        claimThrone(string(msg.data));
    }

    function claimThrone(string name) {
        uint256 valuePaid = msg.value;
        if (valuePaid < currentClaimPrice) {
            bool __sent_result103 = msg.sender.send(valuePaid);
            require(__sent_result103);
            return;
        }

        if (valuePaid > currentClaimPrice) {
            uint256 excessPaid = valuePaid - currentClaimPrice;
            bool __sent_result104 = msg.sender.send(excessPaid);
            require(__sent_result104);
            valuePaid = valuePaid - excessPaid;
        }

        uint256 wizardCommission = (valuePaid * wizardCommissionFractionNum) /
            wizardCommissionFractionDen;
        uint256 compensation = valuePaid - wizardCommission;
        if (currentMonarch.etherAddress != wizardAddress) {
            bool __sent_result105 = currentMonarch.etherAddress.send(
                compensation
            );
            require(__sent_result105);
        } else {}

        pastMonarchs.push(currentMonarch);
        currentMonarch = Monarch(msg.sender, name, valuePaid, block.timestamp);
        uint256 rawNewClaimPrice = (currentClaimPrice * claimPriceAdjustNum) /
            claimPriceAdjustDen;
        if (rawNewClaimPrice < 10 finney) {
            currentClaimPrice = rawNewClaimPrice;
        } else if (rawNewClaimPrice < 100 finney) {
            currentClaimPrice = 100 szabo * (rawNewClaimPrice / 100 szabo);
        } else if (rawNewClaimPrice < 1 ether) {
            currentClaimPrice = 1 finney * (rawNewClaimPrice / 1 finney);
        } else if (rawNewClaimPrice < 10 ether) {
            currentClaimPrice = 10 finney * (rawNewClaimPrice / 10 finney);
        } else if (rawNewClaimPrice < 100 ether) {
            currentClaimPrice = 100 finney * (rawNewClaimPrice / 100 finney);
        } else if (rawNewClaimPrice < 1000 ether) {
            currentClaimPrice = 1 ether * (rawNewClaimPrice / 1 ether);
        } else if (rawNewClaimPrice < 10000 ether) {
            currentClaimPrice = 10 ether * (rawNewClaimPrice / 10 ether);
        } else {
            currentClaimPrice = rawNewClaimPrice;
        }

        ThroneClaimed(
            currentMonarch.etherAddress,
            currentMonarch.name,
            currentClaimPrice
        );
    }

    function sweepCommission(uint256 amount) onlywizard {
        bool __sent_result106 = wizardAddress.send(amount);
        require(__sent_result106);
    }

    function transferOwnership(address newOwner) onlywizard {
        wizardAddress = newOwner;
    }
}
