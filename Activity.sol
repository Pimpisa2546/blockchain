// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CouponBooking {
    struct CouponReservation {
        uint256 couponId;
        address user;
        uint256 timeSlot;
        uint256 price;
        string couponName;
    }

    mapping(uint256 => CouponReservation) public reservations;
    mapping(uint256 => mapping(uint256 => bool)) public couponSchedule; // couponId => timeSlot => isBooked
    mapping(address => uint256[]) public userReservations;
    
    uint256 public nextReservationId = 1;
    address public owner;
    
    event ReservationCreated(
        uint256 indexed reservationId,
        uint256 indexed couponId,
        address indexed user,
        uint256 timeSlot,
        string couponName
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function reserveCoupon(uint256 couponId) external payable {
        require(msg.value == 0.0001 ether, "Incorrect payment amount");
        require(!couponSchedule[couponId][block.timestamp], "Coupon already booked for this time");
        
        uint256 reservationId = nextReservationId++;
        
        reservations[reservationId] = CouponReservation({
            couponId: couponId,
            user: msg.sender,
            timeSlot: block.timestamp,
            price: msg.value,
            couponName: getCouponName(couponId)
        });

        couponSchedule[couponId][block.timestamp] = true;
        userReservations[msg.sender].push(reservationId);

        emit ReservationCreated(
            reservationId,
            couponId,
            msg.sender,
            block.timestamp,
            getCouponName(couponId)
        );
    }

    function getAllReservations() external view returns (
        uint256[] memory times,
        string[] memory coupons,
        address[] memory users
    ) {
        uint256 totalReservations = nextReservationId - 1;
        times = new uint256[](totalReservations);
        coupons = new string[](totalReservations);
        users = new address[](totalReservations);

        for (uint256 i = 1; i <= totalReservations; i++) {
            CouponReservation storage res = reservations[i];
            times[i-1] = res.timeSlot;
            coupons[i-1] = res.couponName;
            users[i-1] = res.user;
        }

        return (times, coupons, users);
    }

    function getCouponName(uint256 couponId) internal pure returns (string memory) {
        if (couponId == 1) return "Coupon A";
        if (couponId == 2) return "Coupon B";
        if (couponId == 3) return "Coupon C";
        return "Unknown Coupon";
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
