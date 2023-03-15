// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

    /// @title A blockchain-based hotel booking smart contract
    /// @author Vicentia Pius
    /// @notice This contract is used by a hotel to add its rooms and customer activities can be carried out here 
contract Booking {
    //enum Class{lowBudget, economy, executive}
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

    event RoomAdded (address indexed Admin, uint32 roomPrice);
    event Booked (address indexed customer, uint RoomId, uint daysReserved, string message);
    event CheckedIn (address customer, string message);
    event Checkedout (address customer, string message);
    event ownerChanged (address indexed _newOwner);

    struct Rooms{
        uint24 roomId;
        uint32 pricePerDay;
        bool bookingStatus;
        string roomDescription;
        bool ownerCheckedIn;
        bool ownerCheckedOut;
    }
        // Rooms are placed in different categories based on prices.
    Rooms [] lowBudget;
    Rooms [] economy;
    Rooms [] executive;


    mapping (uint24 => Rooms) public roomsTrack;
    mapping (address => uint24) public roomOwner;

        /// @notice Only contract owner Adds a new room to the list of hotel rooms.
        /// @param _price The booking price of the room to be listed
        /// @param _roomDescription describes the facilities in the room and benefits customer gets for reserving this room.
        /// @notice the room price determines the category of the room: lowBudget, Economy or Executive.

    function addRoom (uint32 _price, string memory _roomDescription) external Owner {
        uint24 ID = roomId++;
        Rooms storage rooms = roomsTrack[ID];
        rooms.roomId = ID;
        rooms.pricePerDay = _price;
        rooms.roomDescription = _roomDescription;
        rooms.bookingStatus = false;
        rooms.ownerCheckedIn = false;

        if (_price <= 1000) {
            lowBudget.push(rooms);
        } else if(_price >= 1001 && _price <= 30000) {
            economy.push(rooms);
        } else{
            executive.push(rooms);
        }
        emit RoomAdded(owner, _price);
    }

        /// @notice function for customer to book room in the hotel.
        /// @param _roomId is the identification number of the room customer wishes to reserve.
        /// @param numberOfDays number of days customer will be staying at the hotel.
        /// @notice it is a payable function.

    function bookRoom (uint24 _roomId, uint32 numberOfDays) external payable {
        Rooms storage rooms = roomsTrack[_roomId];
        if(msg.sender == address(0)) {
            revert("Zero address cannot book a room");
        }
        if(rooms.bookingStatus == true){
            revert("This room is already booked");
        }
        if(Token.balanceOf(msg.sender) != rooms.pricePerDay * numberOfDays) {
            revert("You do not have enough cUSD to pay for this room");
        }
        roomOwner[msg.sender] = _roomId;
        rooms.bookingStatus = true;
        emit Booked(msg.sender, _roomId, numberOfDays, "Thank you for reserving a room at our hotel! We hope to have you soon.");
    }
        /// @notice function to see all low budget rooms
        /// @return all rooms in the low budget array 

    function seeAllLowBudget () external view returns (Rooms[] memory ){
        uint24 noOfRooms = uint24(lowBudget.length);
        Rooms[] memory lowBRooms = new Rooms [](noOfRooms);

        for (uint24 index = 0; index < noOfRooms; index++) {
           Rooms storage _rooms = lowBudget[index];
           lowBRooms[index] = _rooms;
        }
        return lowBRooms;
    }

        /// @notice function to see all economy rooms
        /// @return all rooms in the economy array

    function seeAllEconomyRooms () external view returns (Rooms [] memory){
        uint24 noOfRooms = uint24(economy.length);
        Rooms[] memory Economy = new Rooms [](noOfRooms);

        for (uint256 index = 0; index < noOfRooms; index++) {
            Rooms storage _Rooms = economy[index];
            Economy[index] = _Rooms;
        }
        return Economy;
    }

        /// @notice function to see all executive rooms
        /// @return all rooms in the executive array

    function seeAllExecutiveRooms () external view returns( Rooms [] memory){
        uint24 noOfRooms = uint24(executive.length);
        Rooms [] memory Executive = new Rooms [](noOfRooms);

        for (uint256 index = 0; index < noOfRooms; index++) {
            Rooms storage _Executive = executive[index];
            Executive[index] = _Executive;
        }
        return Executive;
    }

     /// @notice customer checks in to reserved room.
     /// @param _roomId the room ID number the customer reserved.
     ///@notice if this room ID is does not tally with the id the customer reserved, fuction throws an error.

    function checkedIn(uint24 _roomId) external {
        Rooms storage rooms = roomsTrack[_roomId];
        require(roomOwner[msg.sender] == _roomId, "You did not book this room");
        rooms.ownerCheckedIn = true;
        emit CheckedIn(msg.sender, "You have successfully checked in to your reserved room. We hope you enjoy stay here.");
    }

    /// @notice customer checks out of reserved room.
    /// @param _roomId room ID of room customer is checking out of.

    function checkedOut(uint24 _roomId) external {
        roomOwner[msg.sender] = _roomId;
        Rooms storage rooms = roomsTrack[_roomId];

        rooms.bookingStatus = false;
        rooms.ownerCheckedOut = true;
        rooms.ownerCheckedIn = false;
        delete roomOwner[msg.sender];
        emit Checkedout(msg.sender, "You have successfully checked out of this room. We trust you had a pleasant stay here.");
   }

    /// @notice contract owner withdraws contract balance.
    /// @param _receiver the address the contract balance is being withdrawn to.

    function withdrawBalance(address payable _receiver) external Owner {
        _receiver.transfer(address(this).balance);
        //(bool sent, bytes memory data) = _receiver.call{value: address(this).balance}("");
        //require(sent, "Transaction unsuccessful");
    }

    /// @notice function to view contract balance.
    /// @return the balabce of contract.

    function getBalance() external view Owner returns(uint){
        return address(this).balance;
    }

    /// @notice changing contract admin/owner.
    /// @param newOwner the address to be set as new contract owner.
    function changeOwner(address newOwner) external Owner{
        owner = newOwner;
        emit ownerChanged(newOwner);
    }
}


