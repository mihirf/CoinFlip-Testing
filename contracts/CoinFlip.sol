pragma solidity 0.5.12;
import "./Ownable.sol";
import "./OracleCode.sol";
import "./Destroyable.sol";

contract CoinFlip is Ownable, sendOracleQuery, Destroyable{

    mapping(address => Player) _Players;

    event success(uint256 num);

    struct Player{
        uint256 balanceDeposited;
        uint256 balanceWon;
        uint256 wins;
        uint256 losses;
        uint256 randomInt;
    }

    function betAmount(string memory option) public payable{
        require(msg.value >= 0.1 ether, "You need to place a bet greater than or equal to 0.1 ether");
        require(msg.value * 2 < address(this).balance, "Betting amount is greater than contract balance.");
        require((_Players[msg.sender].balanceWon + (2 * msg.value)) < address(this).balance, "Withdraw balance exceeds contract's balance.");
        require(msg.sender != owner, "Contract owner cannot place bets.");
        _Players[msg.sender].balanceDeposited = msg.value;
        update();
        headsOrTails(option);
    }

    function headsOrTails(string memory option) private {
        uint256 value = randomInt[msg.sender][queryIDs[msg.sender]];
        if(value == 0 && keccak256(abi.encodePacked(option)) == keccak256(abi.encodePacked("Heads"))){
            _Players[msg.sender].balanceWon += 2 * _Players[msg.sender].balanceDeposited;
            _Players[msg.sender].balanceDeposited = 0;
            _Players[msg.sender].wins++;
        }
        else if (value == 1 && keccak256(abi.encodePacked(option)) == keccak256(abi.encodePacked("Tails"))){
          _Players[msg.sender].balanceWon += 2 * _Players[msg.sender].balanceDeposited;
            _Players[msg.sender].balanceDeposited = 0;
            _Players[msg.sender].wins++;
        }
        else{
            _Players[address(this)].balanceDeposited = _Players[msg.sender].balanceDeposited;
            _Players[msg.sender].balanceDeposited = 0;
            _Players[msg.sender].losses++;
        }
        emit success(value);
    }

    function claimRewards() public payable{
        require(_Players[msg.sender].balanceWon >= 0.1 ether, "You have no rewards to claim.");
        require(address(this).balance > _Players[msg.sender].balanceWon, "Withdraw balance exceeds contract's balance.");
        uint256 amount = _Players[msg.sender].balanceWon;
        _Players[msg.sender].balanceWon = 0;
        _Players[msg.sender].balanceDeposited =0;
        msg.sender.transfer(amount);
    }
    function withdrawAll() public payable onlyOwner{
        msg.sender.transfer(address(this).balance);
    }

    function checkContractBalance() public view returns(uint256){
        return address(this).balance;
    }

    function depositIntoContract() public payable onlyOwner{
         _Players[address(this)].balanceDeposited = msg.value;
    }

    function getAccountBalance() public view returns(uint256){
        return _Players[msg.sender].balanceWon;
    }

    function getPlayer() public view returns(uint256, uint256, uint256, uint256, uint256){
        return (_Players[msg.sender].balanceDeposited, _Players[msg.sender].balanceWon, _Players[msg.sender].wins, _Players[msg.sender].losses, _Players[msg.sender].randomInt);
    }

}
