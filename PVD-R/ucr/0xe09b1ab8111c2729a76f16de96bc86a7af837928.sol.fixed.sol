pragma solidity ^0.4.24;

contract sGuardPlus {
    constructor() internal {}

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract FiftyFlip is sGuardPlus {
    uint256 constant DONATING_X = 20;
    uint256 constant JACKPOT_FEE = 10;
    uint256 constant JACKPOT_MODULO = 1000;
    uint256 constant DEV_FEE = 20;
    uint256 constant WIN_X = 1900;
    uint256 constant MIN_BET = 0.01 ether;
    uint256 constant MAX_BET = 1 ether;
    uint256 constant BET_EXPIRATION_BLOCKS = 250;
    address public owner;
    address public autoPlayBot;
    address public secretSigner;
    address private whale;
    uint256 public jackpotSize;
    uint256 public devFeeSize;
    uint256 public lockedInBets;
    uint256 public totalAmountToWhale;
    struct Bet {
        uint256 amount;
        uint256 blockNumber;
        bool betMask;
        address player;
    }
    mapping(uint256 => Bet) bets;
    mapping(address => uint256) donateAmount;
    event Wager(
        uint256 ticketID,
        uint256 betAmount,
        uint256 betBlockNumber,
        bool betMask,
        address betPlayer
    );
    event Win(
        address winner,
        uint256 amount,
        uint256 ticketID,
        bool maskRes,
        uint256 jackpotRes
    );
    event Lose(
        address loser,
        uint256 amount,
        uint256 ticketID,
        bool maskRes,
        uint256 jackpotRes
    );
    event Refund(uint256 ticketID, uint256 amount, address requester);
    event Donate(uint256 amount, address donator);
    event FailedPayment(address paidUser, uint256 amount);
    event Payment(address noPaidUser, uint256 amount);
    event JackpotPayment(address player, uint256 ticketID, uint256 jackpotWin);

    constructor(
        address whaleAddress,
        address autoPlayBotAddress,
        address secretSignerAddress
    ) public {
        owner = msg.sender;
        autoPlayBot = autoPlayBotAddress;
        whale = whaleAddress;
        secretSigner = secretSignerAddress;
        jackpotSize = 0;
        devFeeSize = 0;
        lockedInBets = 0;
        totalAmountToWhale = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner of this contract!");
        _;
    }
    modifier onlyBot() {
        require(
            msg.sender == autoPlayBot,
            "You are not the bot of this contract!"
        );
        _;
    }
    modifier checkContractHealth() {
        require(
            address(this).balance >= lockedInBets + jackpotSize + devFeeSize,
            "This contract doesn't have enough balance, it is stopped till someone donate to this game!"
        );
        _;
    }

    function() public payable {}

    function setBotAddress(address autoPlayBotAddress) external onlyOwner {
        autoPlayBot = autoPlayBotAddress;
    }

    function setSecretSigner(address _secretSigner) external onlyOwner {
        secretSigner = _secretSigner;
    }

    function wager(
        bool bMask,
        uint256 ticketID,
        uint256 ticketLastBlock,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable checkContractHealth {
        Bet storage bet = bets[ticketID];
        uint256 amount = msg.value;
        address player = msg.sender;
        require(bet.player == address(0), "Ticket is not new one!");
        require(amount >= MIN_BET, "Your bet is lower than minimum bet amount");
        require(
            amount <= MAX_BET,
            "Your bet is higher than maximum bet amount"
        );
        require(
            getCollateralBalance() >= 2 * amount,
            "If we accept this, this contract will be in danger!"
        );
        require(block.number <= ticketLastBlock, "Ticket has expired.");
        bytes32 signatureHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n37",
                uint40(ticketLastBlock),
                ticketID
            )
        );
        require(
            secretSigner == ecrecover(signatureHash, v, r, s),
            "web3 vrs signature is not valid."
        );
        jackpotSize += (amount * JACKPOT_FEE) / 1000;
        devFeeSize += (amount * DEV_FEE) / 1000;
        lockedInBets += (amount * WIN_X) / 1000;
        uint256 donate_amount = (amount * DONATING_X) / 1000;
        bool __sent_result100 = whale.call.value(donate_amount)(
            bytes4(keccak256("donate()"))
        );
        require(__sent_result100);
        totalAmountToWhale += donate_amount;
        bet.amount = amount;
        bet.blockNumber = block.number;
        bet.betMask = bMask;
        bet.player = player;
        emit Wager(
            ticketID,
            bet.amount,
            bet.blockNumber,
            bet.betMask,
            bet.player
        );
    }

    function play(uint256 ticketReveal) external checkContractHealth {
        uint256 ticketID = uint256(keccak256(abi.encodePacked(ticketReveal)));
        Bet storage bet = bets[ticketID];
        require(bet.player != address(0), "TicketID is not correct!");
        require(bet.amount != 0, "Ticket is already used one!");
        uint256 blockNumber = bet.blockNumber;
        if (
            blockNumber < block.number &&
            blockNumber >= block.number - BET_EXPIRATION_BLOCKS
        ) {
            uint256 random = uint256(
                keccak256(
                    abi.encodePacked(blockhash(blockNumber), ticketReveal)
                )
            );
            bool maskRes = (random % 2) != 0;
            uint256 jackpotRes = random % JACKPOT_MODULO;
            uint256 tossWinAmount = (bet.amount * WIN_X) / 1000;
            uint256 tossWin = 0;
            uint256 jackpotWin = 0;
            if (bet.betMask == maskRes) {
                tossWin = tossWinAmount;
            }

            if (jackpotRes == 0) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }

            if (jackpotWin > 0) {
                emit JackpotPayment(bet.player, ticketID, jackpotWin);
            }

            if (tossWin + jackpotWin > 0) {
                payout(
                    bet.player,
                    tossWin + jackpotWin,
                    ticketID,
                    maskRes,
                    jackpotRes
                );
            } else {
                loseWager(
                    bet.player,
                    bet.amount,
                    ticketID,
                    maskRes,
                    jackpotRes
                );
            }

            lockedInBets -= tossWinAmount;
            bet.amount = 0;
        } else {
            revert();
        }
    }

    function donateForContractHealth() external payable {
        donateAmount[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function withdrawDonation(uint256 amount) external {
        require(
            donateAmount[msg.sender] >= amount,
            "You are going to withdraw more than you donated!"
        );
        if (sendFunds(msg.sender, amount)) {
            donateAmount[msg.sender] -= amount;
        }
    }

    function refund(uint256 ticketID) external checkContractHealth {
        Bet storage bet = bets[ticketID];
        require(bet.amount != 0, "this ticket has no balance");
        require(
            block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS,
            "this ticket is expired."
        );
        sendRefund(ticketID);
    }

    function withdrawDevFee(address withdrawAddress, uint256 withdrawAmount)
        external
        onlyOwner
        checkContractHealth
    {
        require(
            devFeeSize >= withdrawAmount,
            "You are trying to withdraw more amount than developer fee."
        );
        require(
            withdrawAmount <= address(this).balance,
            "Contract balance is lower than withdrawAmount"
        );
        require(
            devFeeSize <= address(this).balance,
            "Not enough funds to withdraw."
        );
        if (sendFunds(withdrawAddress, withdrawAmount)) {
            devFeeSize -= withdrawAmount;
        }
    }

    function withdrawBotFee(uint256 withdrawAmount)
        external
        onlyBot
        checkContractHealth
    {
        require(
            devFeeSize >= withdrawAmount,
            "You are trying to withdraw more amount than developer fee."
        );
        require(
            withdrawAmount <= address(this).balance,
            "Contract balance is lower than withdrawAmount"
        );
        require(
            devFeeSize <= address(this).balance,
            "Not enough funds to withdraw."
        );
        if (sendFunds(autoPlayBot, withdrawAmount)) {
            devFeeSize -= withdrawAmount;
        }
    }

    function getBetInfo(uint256 ticketID)
        external
        constant
        returns (
            uint256,
            uint256,
            bool,
            address
        )
    {
        Bet storage bet = bets[ticketID];
        return (bet.amount, bet.blockNumber, bet.betMask, bet.player);
    }

    function getContractBalance() external constant returns (uint256) {
        return address(this).balance;
    }

    function getCollateralBalance() public constant returns (uint256) {
        if (address(this).balance > lockedInBets + jackpotSize + devFeeSize)
            return
                address(this).balance - lockedInBets - jackpotSize - devFeeSize;

        return 0;
    }

    function kill() external onlyOwner {
        require(
            lockedInBets == 0,
            "All bets should be processed (settled or refunded) before self-destruct."
        );
        selfdestruct(owner);
    }

    function payout(
        address winner,
        uint256 ethToTransfer,
        uint256 ticketID,
        bool maskRes,
        uint256 jackpotRes
    ) internal {
        winner.transfer(ethToTransfer);
        emit Win(winner, ethToTransfer, ticketID, maskRes, jackpotRes);
    }

    function sendRefund(uint256 ticketID) internal {
        Bet storage bet = bets[ticketID];
        address requester = bet.player;
        uint256 ethToTransfer = bet.amount;
        requester.transfer(ethToTransfer);
        uint256 tossWinAmount = (bet.amount * WIN_X) / 1000;
        lockedInBets -= tossWinAmount;
        bet.amount = 0;
        emit Refund(ticketID, ethToTransfer, requester);
    }

    function sendFunds(address paidUser, uint256 amount)
        private
        returns (bool)
    {
        bool success = paidUser.send(amount);
        if (success) {
            emit Payment(paidUser, amount);
        } else {
            emit FailedPayment(paidUser, amount);
        }

        return success;
    }

    function loseWager(
        address player,
        uint256 amount,
        uint256 ticketID,
        bool maskRes,
        uint256 jackpotRes
    ) internal {
        emit Lose(player, amount, ticketID, maskRes, jackpotRes);
    }

    function clearStorage(uint256[] toCleanTicketIDs) external {
        uint256 length = toCleanTicketIDs.length;
        for (uint256 i = 0; i < length; i = add_uint(i, 1)) {
            clearProcessedBet(toCleanTicketIDs[i]);
        }
    }

    function clearProcessedBet(uint256 ticketID) private {
        Bet storage bet = bets[ticketID];
        if (
            bet.amount != 0 ||
            block.number <= bet.blockNumber + BET_EXPIRATION_BLOCKS
        ) {
            return;
        }

        bet.blockNumber = 0;
        bet.betMask = false;
        bet.player = address(0);
    }

    function transferAnyERC20Token(
        address tokenAddress,
        address tokenOwner,
        uint256 tokens
    ) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
    }
}

contract ERC20Interface {
    function transfer(address to, uint256 tokens) public returns (bool success);
}
