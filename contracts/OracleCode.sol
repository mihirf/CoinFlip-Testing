pragma solidity 0.5.12;

import "./provableAPI.sol";

contract sendOracleQuery{

    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;

    mapping(address => mapping(bytes32 => uint256)) public randomInt;
    mapping(address => bytes32) public queryIDs;

    event LogNewProvableQuery(string description);
    event generatedRandomNumber (uint256 randomNumber);

    constructor() public{
        update();// Free random number only once
    }

    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public{
        //require(msg.sender == provable_cbAddress());
        randomInt[msg.sender][_queryId] = uint256(keccak256(abi.encodePacked(_result))) % 4;
        emit generatedRandomNumber(randomInt[msg.sender][queryIDs[msg.sender]]);
    }

    function update() payable public{
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        testRandom();
        //queryIDs[msg.sender] = provable_newRandomDSQuery(QUERY_EXECUTION_DELAY, NUM_RANDOM_BYTES_REQUESTED, GAS_FOR_CALLBACK); //returns a query id
        emit LogNewProvableQuery ("Provable query was sent, standing by for the answer...");
    }
    function testRandom() public returns (bytes32){
        queryIDs[msg.sender] = bytes32(keccak256("test"));
        __callback(queryIDs[msg.sender], "2", bytes("test"));
        return queryIDs[msg.sender];
    }

    function getRandomNumber()public view returns(uint256){
        return randomInt[msg.sender][queryIDs[msg.sender]];
    }



}
