pragma solidity ^0.4.0;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mul_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
}

contract Lotto is sGuardPlus {
    uint256 public constant blocksPerRound = 6800;
    uint256 public constant ticketPrice = 100000000000000000;
    uint256 public constant blockReward = 5000000000000000000;

    function getBlocksPerRound() constant returns (uint256) {
        return blocksPerRound;
    }

    function getTicketPrice() constant returns (uint256) {
        return ticketPrice;
    }

    struct Round {
        address[] buyers;
        uint256 pot;
        uint256 ticketsCount;
        mapping(uint256 => bool) isCashed;
        mapping(address => uint256) ticketsCountByBuyer;
    }
    mapping(uint256 => Round) rounds;

    function getRoundIndex() constant returns (uint256) {
        return block.number / blocksPerRound;
    }

    function getIsCashed(uint256 roundIndex, uint256 subpotIndex)
        constant
        returns (bool)
    {
        return rounds[roundIndex].isCashed[subpotIndex];
    }

    function calculateWinner(uint256 roundIndex, uint256 subpotIndex)
        constant
        returns (address)
    {
        var decisionBlockNumber = getDecisionBlockNumber(
            roundIndex,
            subpotIndex
        );
        if (decisionBlockNumber > block.number) return;

        var decisionBlockHash = getHashOfBlock(decisionBlockNumber);
        var winningTicketIndex = decisionBlockHash %
            rounds[roundIndex].ticketsCount;
        var ticketIndex = uint256(0);
        for (
            var buyerIndex = 0;
            buyerIndex < rounds[roundIndex].buyers.length;
            buyerIndex++
        ) {
            var buyer = rounds[roundIndex].buyers[buyerIndex];
            ticketIndex += rounds[roundIndex].ticketsCountByBuyer[buyer];
            if (ticketIndex > winningTicketIndex) {
                return buyer;
            }
        }
    }

    function getDecisionBlockNumber(uint256 roundIndex, uint256 subpotIndex)
        constant
        returns (uint256)
    {
        return
            add_uint(
                (mul_uint((add_uint(roundIndex, 1)), blocksPerRound)),
                subpotIndex
            );
    }

    function getSubpotsCount(uint256 roundIndex) constant returns (uint256) {
        var subpotsCount = rounds[roundIndex].pot / blockReward;
        if (rounds[roundIndex].pot % blockReward > 0) subpotsCount++;

        return subpotsCount;
    }

    function getSubpot(uint256 roundIndex) constant returns (uint256) {
        return rounds[roundIndex].pot / getSubpotsCount(roundIndex);
    }

    function cash(uint256 roundIndex, uint256 subpotIndex) {
        var subpotsCount = getSubpotsCount(roundIndex);
        if (subpotIndex >= subpotsCount) return;

        var decisionBlockNumber = getDecisionBlockNumber(
            roundIndex,
            subpotIndex
        );
        if (decisionBlockNumber > block.number) return;

        if (rounds[roundIndex].isCashed[subpotIndex]) return;

        var winner = calculateWinner(roundIndex, subpotIndex);
        var subpot = getSubpot(roundIndex);
        bool __sent_result100 = winner.send(subpot);
        require(__sent_result100);
        rounds[roundIndex].isCashed[subpotIndex] = true;
    }

    function getHashOfBlock(uint256 blockIndex) constant returns (uint256) {
        return uint256(block.blockhash(blockIndex));
    }

    function getBuyers(uint256 roundIndex, address buyer)
        constant
        returns (address[])
    {
        return rounds[roundIndex].buyers;
    }

    function getTicketsCountByBuyer(uint256 roundIndex, address buyer)
        constant
        returns (uint256)
    {
        return rounds[roundIndex].ticketsCountByBuyer[buyer];
    }

    function getPot(uint256 roundIndex) constant returns (uint256) {
        return rounds[roundIndex].pot;
    }

    function() {
        var roundIndex = getRoundIndex();
        var value = msg.value - (msg.value % ticketPrice);
        if (value == 0) return;

        if (value < msg.value) {
            bool __sent_result102 = msg.sender.send(msg.value - value);
            require(__sent_result102);
        }

        var ticketsCount = value / ticketPrice;
        rounds[roundIndex].ticketsCount += ticketsCount;
        if (rounds[roundIndex].ticketsCountByBuyer[msg.sender] == 0) {
            var buyersLength = rounds[roundIndex].buyers.length++;
            rounds[roundIndex].buyers[buyersLength] = msg.sender;
        }

        rounds[roundIndex].ticketsCountByBuyer[msg.sender] += ticketsCount;
        rounds[roundIndex].ticketsCount += ticketsCount;
        rounds[roundIndex].pot += value;
    }
}
