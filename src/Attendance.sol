// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract Attendance {
    address owner;
    // Struct to hold courses and their lecturers
    struct Course {
        string Department;
        string CourseName;
        string LecturerName;
        string MycourseCode;
        address Lecturer;
        uint256 AttendanceCounter;
        uint256 TotalStudent;
        address[] RegStdntDetails;
        uint256 _codeAttendance;
        mapping(address => bool) registeredStudents;
        mapping(uint256 => bool) attendanceCode;
        mapping(address => uint256) assessmentScore;
        mapping(address => mapping(uint256 => bool)) RecentAttendance;
        mapping(address => uint256) StudentAttendance;
        bool courseStatus;
    }
    mapping(string => Course) public CourseCode;

    string[] AllCourses;
    // struct to hold student Details
    struct studentDetails {
        address myAddress;
        string StudentName;
        string Department;
        string Level;
        bool StudentStatus;
        string[] AllCourses;
    }

    mapping(address => studentDetails) studentDetail;

    mapping(address => bool) Admin;
    mapping(address => bool) lecturer;
    address[] AllStudentAddresses;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(address _owner) {
        require(_owner == owner, "NOT_OWNER");
        _;
    }
    modifier onlyAdmin(address _admin) {
        require(Admin[_admin] = true, "NOT_ADMIN");
        _;
    }
    // set admin
    // only owner can create Admin
    function setAdmin(
        address _owner,
        address _newAdmin
    ) external onlyOwner(_owner) {
        Admin[_newAdmin] = true;
    }

    

    // create Course
    // Admin create Course
    function createCourse(
        string memory _courseCode,
        string memory _courseName,
        address _admin,
        string memory _department
    ) external onlyAdmin(_admin) {
        require(
            CourseCode[_courseCode].courseStatus == false,
            "COURSE_REGISTERED"
        );
        CourseCode[_courseCode].courseStatus = true;
        CourseCode[_courseCode].Department = _department;
        CourseCode[_courseCode].CourseName = _courseName;
        CourseCode[_courseCode].MycourseCode = _courseCode;
        AllCourses.push(_courseCode);
    }

    // assign lecturers to a particular course
    // Admin registers Lecturer and add them to the course
    function assignLecturers(
        string memory _courseCode,
        string memory _lecturerName,
        address _lecturer
    ) external {
        require(
            CourseCode[_courseCode].courseStatus == true,
            "COURSE_NOT_REGISTERED"
        );
        require(
            CourseCode[_courseCode].Lecturer == address(0),
            "LECTURER_ASSIGNED"
        );
        lecturer[_lecturer] = true;
        CourseCode[_courseCode].LecturerName = _lecturerName;
        CourseCode[_courseCode].Lecturer = _lecturer;
    }

    // Admin registers Student

    function registerStudentDetails(
        address _student,
        string memory _studentName,
        string memory _level,
        string memory _department
    ) external onlyAdmin(msg.sender) {
        require(
            studentDetail[_student].StudentStatus == false,
            "STUDENT_REGISTERED"
        );
        studentDetail[_student].StudentName = _studentName;
        studentDetail[_student].Department = _department;
        studentDetail[_student].Level = _level;
        studentDetail[_student].StudentStatus = true;
        studentDetail[_student].myAddress = _student ;
        AllStudentAddresses.push(_student);
    }

    // register student
    // Admin add student to the cousrse

    // register student to a particular Course
    function registerStudentToCourse(
        address _student,
        string memory _courseCode,
        address _admin
    ) external onlyAdmin(_admin) {
        require(
            CourseCode[_courseCode].courseStatus == true,
            "COURSE_NOT_REGISTERED"
        );
        require(
            CourseCode[_courseCode].registeredStudents[_student] == false,
            "STUDENT_REGISTERED"
        );
        CourseCode[_courseCode].registeredStudents[_student] = true;
       CourseCode[_courseCode].TotalStudent +=1;
       CourseCode[_courseCode].RegStdntDetails.push(_student);

       studentDetail[_student].AllCourses.push(_courseCode);
    }

    // create Attendance
    // random number generated
     function createAttendanceCode(
        string memory _courseCode
    ) external onlyAdmin(msg.sender) returns (uint256) {
        require(
            CourseCode[_courseCode].courseStatus == true,
            "COURSE_NOT_REGISTERED"
        );
        require(
            CourseCode[_courseCode].Lecturer == msg.sender,
            "NOT_THE_LECTURER"
        );

    uint hashNumber =  uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender)));
 
        // uint randomNumber = block.prevrandao;
  
     uint randomNumber =hashNumber % 100;
    
        CourseCode[_courseCode].AttendanceCounter += 1;
        CourseCode[_courseCode].attendanceCode[randomNumber] = true;
        CourseCode[_courseCode]._codeAttendance = randomNumber;
        return randomNumber;
    }   // Lecturers generate attendance code for their student


    //     close attendance
    function closeAttendance(
        string memory _courseCode,
        uint256 _randomNumber
    ) external {
        require(
            CourseCode[_courseCode].courseStatus == true,
            "COURSE_NOT_REGISTERED"
        );
        require(
            CourseCode[_courseCode].Lecturer == msg.sender,
            "NOT_THE_LECTURER"
        );
        delete CourseCode[_courseCode].attendanceCode[_randomNumber];
    }

    // Student Marks attendance
    // STudent marks attendance
    function markAttendance(
        string memory _courseCode,
        uint256 _randomNumber,
        address _student
    ) external {
        require(_student == msg.sender, "NOT_ADDRESS_OWNER");
        require(
            CourseCode[_courseCode].courseStatus == true,
            "COURSE_NOT_REGISTERED"
        );
        require(
            CourseCode[_courseCode].registeredStudents[_student] == true,
            "STUDENT_NOT_REGISTERED"
        );
        require(
            CourseCode[_courseCode].attendanceCode[_randomNumber] == true,
            "ATTENDANCE_DOES_NOT_EXIT"
        );
        require(
            CourseCode[_courseCode].RecentAttendance[_student][_randomNumber] ==
                false,
            "ATTENDANCE_MARKED"
        );

        CourseCode[_courseCode].RecentAttendance[_student][
            _randomNumber
        ] = true;

        CourseCode[_courseCode].StudentAttendance[_student] += 1;
    }

// get all registered courses
function getAllCourses() external view returns (string[] memory, string[] memory, address[] memory, string[] memory, uint256[] memory, string[] memory) {
    string[] memory departments = new string[](AllCourses.length);
    string[] memory courseNames = new string[](AllCourses.length);
    address[] memory lecturerAddresses = new address[](AllCourses.length);
    string[] memory lecturerNames = new string[](AllCourses.length);
    string[] memory _mycourseCode = new string[](AllCourses.length);
    uint256[] memory noOfStudents = new uint256[](AllCourses.length);

    for (uint i = 0; i < AllCourses.length; i++) {
        Course storage course = CourseCode[AllCourses[i]];

        departments[i] = course.Department;
        courseNames[i] = course.CourseName;
        lecturerAddresses[i] = course.Lecturer;
        lecturerNames[i] = course.LecturerName;
        noOfStudents[i] = course.TotalStudent;
        _mycourseCode[i] = course.MycourseCode;
    }

    return (departments, courseNames, lecturerAddresses, lecturerNames, noOfStudents, _mycourseCode);
}

// to get the  details of student in a particular coursecode

function getResgiteredCourseStdt(string memory _courseCode) external view returns(string[] memory, string[] memory, string[] memory, uint256[] memory, uint256[] memory){

   address[] memory allRegisteredStd = CourseCode[_courseCode].RegStdntDetails;
    uint256[] memory _assessmentScore = new uint256[](allRegisteredStd.length);
    uint256[] memory _attendance = new uint256[](allRegisteredStd.length);
    string[] memory studentNames = new string[](allRegisteredStd.length);
    string[] memory _department = new string[](allRegisteredStd.length);
    string[] memory _level = new string[](allRegisteredStd.length);
 

    for (uint256 i = 0; i < allRegisteredStd.length; i++) {
        _assessmentScore[i] = CourseCode[_courseCode].assessmentScore[allRegisteredStd[i]];

        _attendance[i] = CourseCode[_courseCode].StudentAttendance[allRegisteredStd[i]];

        studentNames[i] = studentDetail[allRegisteredStd[i]].StudentName;

        _department[i] = studentDetail[allRegisteredStd[i]].Department;
        _level[i] = studentDetail[allRegisteredStd[i]].Level;
       
    }

    return (studentNames, _department, _level, _assessmentScore, _attendance);

}

function getMyAssignedCourses(address _lecturer) external view returns(string[] memory, uint256 ){
    string[] memory myAssignedCourses = new string[](AllCourses.length);
    uint256 count;
    for(uint256 i= 0; i < AllCourses.length; i++){
        if(CourseCode[AllCourses[i]].Lecturer == _lecturer){

        myAssignedCourses[i] = CourseCode[AllCourses[i]].MycourseCode;
        count ++;
        }
    }
     string[] memory assignedCourses = new string[](count);
    for (uint256 j = 0; j < count; j++) {
        assignedCourses[j] = myAssignedCourses[j];
    }
    return(assignedCourses, count);
}

// myRegisterd Courses
// returns assesment, courses and attendance
    // Student checks attendance percentage
    // Student checks assesment score
function getMyRegisteredCourse(address _studentAddress) external view returns(string[] memory,string[] memory, uint256[] memory, uint256[] memory){
string[] memory myCourses = studentDetail[_studentAddress].AllCourses;

string[] memory _myCourseName = new string[](myCourses.length);
string[] memory _myCourseCode = new string[](myCourses.length);
uint256[] memory _assessmentScore = new uint256[](myCourses.length);
uint256[] memory studentAttendance = new uint256[](myCourses.length);


for(uint i = 0; i < myCourses.length; i++){
    Course storage course = CourseCode[AllCourses[i]];

    _myCourseName[i] = course.CourseName;

    studentAttendance[i] = course.StudentAttendance[_studentAddress];

    _assessmentScore[i] = course.assessmentScore[_studentAddress];
    _myCourseCode[i] = course.MycourseCode;
}
return(_myCourseName,_myCourseCode, studentAttendance, _assessmentScore);

}
function getMySingleCourse(address _studentAddress, string memory _courseCode) external view returns(string memory, uint256, uint256, uint256){
Course storage course = CourseCode[_courseCode];
string memory courseName= course.CourseName;
uint256 myAttendance = course.StudentAttendance[_studentAddress];
uint256 totalAttendance = course.AttendanceCounter;
uint256 attendanceCode = course._codeAttendance;

return(courseName,myAttendance, totalAttendance, attendanceCode);

}

    // get particular student details

    function getStudentDetails(address _studentAddress) external view returns(string memory, string memory, string memory, bool , string[] memory){
    
        studentDetails storage details = studentDetail[_studentAddress];
        return(
            details.StudentName, details.Department, details.Level, details.StudentStatus, details.AllCourses
        );
    }

    function getLecturerStatus(address _lecturer) external view returns(bool){
        return lecturer[_lecturer];
    }

    function getStudentStaus(address _student) external view returns(bool){
        return studentDetail[_student].StudentStatus;
    }

    function getAllstudent() external view returns (address[] memory, string[] memory, string[] memory, string[] memory) {
address[] memory _studentAddr = new address[](AllStudentAddresses.length);
string[] memory _studentName = new string[](AllStudentAddresses.length);
string[] memory _department = new string[](AllStudentAddresses.length);
string[] memory _level = new string[](AllStudentAddresses.length);
   
        for(uint256 i = 0; i < AllStudentAddresses.length ; i++){
           studentDetails storage details = studentDetail[AllStudentAddresses[i]];
           _studentAddr[i] = details.myAddress;
           _studentName[i] = details.StudentName;
           _department[i] = details.Department;
           _level[i] = details.Level;
        }

        return(_studentAddr, _studentName,  _department, _level );

    }
    
    // Admin have access to student in a particular Department course


    // Lecturers add exam scores to the student



}
