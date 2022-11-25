// SPDX-License-Identifier: UNLICENSED
 pragma solidity ^0.8.13;

 import "forge-std/Test.sol";
 import "../src/Booking.sol";
 import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CounterTest is Test {
    Booking public booking;
    address User = 0x0b5453635E5325f5385ca1643C9e9EB173f9D5a8;
    IERC20 token = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); 
    function setUp() public {
       booking = new Booking(token);
    }
    function testAddRoom() public{
        uint32 _price = 900;
        string memory _roomDescription = "Spacious room with medium sized bed";
        booking.addRoom(_price, _roomDescription);
        // assertEq(booking.addRoom(_price), 900);
        // assertEq(booking.addRoom( _roomDescription), "Spacious room with single king-size bed");
    }
    function testAddSecondRoom() public {
        uint32 _price = 12000;
        string memory _roomDescription = "King sized bed with access to breakfast, lunch and dinner";
        booking.addRoom(_price, _roomDescription);
    }
    function testAddThirdRoom() public {
        uint32 _price = 50000;
        string memory _roomDescription = "Executive room";
        booking.addRoom(_price, _roomDescription);
    }

 function testAddFourthRoom() public {
        uint32 _price = 600000;
        string memory _roomDescription = "Presidential suite";
        booking.addRoom(_price, _roomDescription);
    }
    function testReturnExecutiveRooms() public view {
        booking.seeAllExecutiveRooms();
    }
    function testBookRoom() public {
        vm.prank(User);
        uint24 _roomId = 2;
        uint32 _days = 2;

        booking.bookRoom(_roomId, _days);
    }
}


/**To book room, I'd have to impersonate an address, which has the USDT token
 * That would be the address that books the room
 */