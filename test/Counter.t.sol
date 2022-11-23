// SPDX-License-Identifier: UNLICENSED
 pragma solidity ^0.8.13;

 import "forge-std/Test.sol";
 import "../src/Booking.sol";
 import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CounterTest is Test {
    Booking public booking;
    IERC20 token = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); 
    function setUp() public {
       booking = new Booking(token);
    }
//     // function testAddRoom() public{
//     //     booking.addRoom(1, "Spacious room with single king-size bed", economy);
//     //     assertEq(booking.addRoom());
//     //     //assertEq(booking.addRoom( _roomDescription), "Spacious room with single king-size bed");
//     // }
}
