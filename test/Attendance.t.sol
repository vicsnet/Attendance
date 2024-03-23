// SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Attendance} from "../src/Attendance.sol";

contract AttendanceTest is Test{
        Attendance public attendance;

        address ox2 = address(0x3);
        address ox3 = address(0x4);
        address ox4 = address(0x5);
        address ox5 = address(0x6);
        address ox6 = address(0x7);
       

        function setUp() public{
                attendance = new Attendance();
                // console.log(address(attendance));
        }

        function test_setAdmin() public{
                attendance.setAdmin(address(this), ox2);
        }
        function test_createCourse()public{
                vm.prank(ox2);
                attendance.createCourse("vin302", "Improvement change", ox2, "Project Management");

                vm.prank(ox2);
                attendance.createCourse("Din302", "Improvement change Characteristic", ox2, "Computer Science");
        }

        function test_assignLecturers() public{
                test_createCourse();
                vm.prank(ox2);
                attendance.assignLecturers("vin302", "Adisa", ox3);
                vm.prank(ox2);
                attendance.assignLecturers("Din302","laurenzo", ox4);
        }

        function test_registerStudentDeatails() public{
                test_assignLecturers();
                attendance.registerStudentDetails(ox5, "Afezat", "level7", "Project Management");
                attendance.registerStudentDetails(ox6, "valentine", "level7", "Computer Science");
        }

        function test_registerStudentToCourse() public{
                test_registerStudentDeatails();
                vm.prank(ox2);
                attendance.registerStudentToCourse(ox5, "vin302", ox2);
                vm.prank(ox2);
                attendance.registerStudentToCourse(ox6, "vin302", ox2);

                vm.prank(ox2);

                attendance.registerStudentToCourse(ox6, "Din302", ox2);
        }

        function test_createAttendanceCode() public{
                test_registerStudentToCourse();
                vm.prank(ox3);
                uint256 code = attendance.createAttendanceCode("vin302");

                vm.prank(ox5);
                attendance.markAttendance("vin302", code, ox5);

                vm.prank(ox3);
                attendance.closeAttendance("vin302", code);

                //  vm.prank(ox6);
                // attendance.markAttendance("vin302", code, ox6);


        }

        function test_getAllCOurses() public{
                test_createAttendanceCode();
                attendance.getAllCourses();
        }

        function test_getRegisteredCourse() public{
                test_createAttendanceCode();
                attendance.getResgiteredCourseStdt("vin302");
        }
        function test_getMyRegisteredCourse() public{
                test_getRegisteredCourse();
                attendance.getMyRegisteredCourse(ox5);
        }

        function test_getStudentDetails() public{
                test_getMyRegisteredCourse();
              attendance.getStudentDetails(ox5);
        }
}