// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Booking {
    enum Class{lowBudget, economy, executive}
    uint24 roomId;
    address owner;
    IERC20 Token;

    constructor (IERC20 _token) {
        owner = msg.sender;
        Token = _token;
    }

    modifier Owner{
       if(msg.sender != owner) {
        revert("Function can only be called by owner");
       }
        _;
    }
    struct Rooms{
        uint24 roomId;
        uint32 pricePerDay;
        bool bookingStatus;
        string roomDescription;
        Class class;
    }

    Rooms [] lowBudget;
    Rooms [] economy;
    Rooms [] executive;


    mapping (uint24 => Rooms) public roomsTrack;
    mapping (address => uint24) public roomOwner;

    function addRoom (uint32 _price, string memory _roomDescription) external Owner {
        uint24 ID = roomId++;
        Rooms storage rooms = roomsTrack[ID];
        rooms.roomId = ID;
        rooms.pricePerDay = _price;
        rooms.roomDescription = _roomDescription;
        rooms.bookingStatus = false;

        if (_price <= 1000) {
            lowBudget.push(rooms);
        } else if(_price >= 1001 && _price <= 30000) {
            economy.push(rooms);
        } else{
            executive.push(rooms);
        }

    }


    function bookRoom (uint24 _roomId, uint32 numberOfDays) external payable {
        Rooms storage rooms = roomsTrack[_roomId];
        if(msg.sender == address(0)) {
            revert("Zero address cannot book a room");
        }
        if(rooms.bookingStatus = true){
            revert("This room is already booked");
        }
        if(Token.balanceOf(msg.sender) != rooms.pricePerDay * numberOfDays) {
            revert("You do not have enough USDT to pay for this room");
        }
        roomOwner[msg.sender] = _roomId;
        rooms.bookingStatus = true;
    }

    function seeAllLowBudget () external view returns (Rooms[] memory ){
        uint24 noOfRooms = uint24(lowBudget.length);
        Rooms[] memory lowBRooms = new Rooms [](noOfRooms);

        for (uint24 index = 0; index < noOfRooms; index++) {
           Rooms storage _rooms = lowBudget[index];
           lowBRooms[index] = _rooms;
        }
        return lowBRooms;
    }

    function seeAllEconomyRooms () external view returns (Rooms [] memory){
        uint24 noOfRooms = uint24(economy.length);
        Rooms[] memory Economy = new Rooms [](noOfRooms);

        for (uint256 index = 0; index < noOfRooms; index++) {
            Rooms storage _Rooms = economy[index];
            Economy[index] = _Rooms;
        }
        return Economy;
    }

    function seeAllExecutiveRooms () external view returns( Rooms [] memory){
        uint24 noOfRooms = uint24(executive.length);
        Rooms [] memory Executive = new Rooms [](noOfRooms);

        for (uint256 index = 0; index < noOfRooms; index++) {
            Rooms storage _Executive = executive[index];
            Executive[index] = _Executive;
        }
        return Executive;
    }

    function withdrawBalance(address payable _receiver) external Owner {
        _receiver.transfer(address(this).balance);
        //(bool sent, bytes memory data) = _receiver.call{value: address(this).balance}("");
        //require(sent, "Transaction unsuccessful");
    }

    function getBalance() external view Owner returns(uint){
        return address(this).balance;
    }
}


