class AttendanceModel {
  final String attDate;
  final String checkingtime;
  final String colckIn;
  final String clockOut;
  final String workplace;
  final String dayName;
  final String status;
  final String remarks;
  final String description;
  final String workinghour;
  final String filepath;
  final String filename;
  final String fileext;
  final String checkinlocation;
  final String checkoutlocation;
  final int present;
  final int absent;
  final int holiday;

  AttendanceModel(
      {
        required this.attDate,
        required this.checkingtime,
        required this.colckIn,
        required this.clockOut,
        required this.workplace,
        required this.dayName,
        required this.status,
        required this.remarks,
        required this.description,
        required this.workinghour,
        required this.filepath,
        required this.filename,
        required this.fileext,
        required this.checkinlocation,
        required this.checkoutlocation,
        required this.present,
        required this.absent,
        required this.holiday
     });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
        attDate: json['AttDate'] ?? '',
        checkingtime: json['CheckingTime'] ?? '',
        colckIn: json['ClockInTime'] ?? '',
        clockOut: json['ClockOutTime'] ?? '',
        workplace: json['Workplace'] ?? '',
        dayName: json['DayName'] ?? '',
        status: json['Status'] ?? '',
        remarks: json['Remarks'] ?? '',
        description: json['Description'] ?? '',
        workinghour:json['WorkingHours'] ?? '',
        filepath: json['Filepath'] ?? '',
        filename: json['OriginalFileName'] ?? '',
        fileext: json['extension'] ?? '',
        checkinlocation: json['Checkin_Location'] ?? '',
        checkoutlocation: json['Checkout_Location'] ?? '',
        present: json['Present'] ?? '',
        absent: json['Absent'] ?? '',
        holiday: json['Holiday'] ?? ''
    );
  }
}
