import 'dart:convert';

import 'package:erp/common/api.dart';
import 'package:erp/common/timeservice.dart';
import 'package:erp/model/attendancemodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:erp/model/global.dart' as globals;
import 'package:intl/intl.dart';

class AttendanceList extends StatefulWidget {
  const AttendanceList({super.key});

  @override
  State<AttendanceList> createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  Api api = Api();
  List<AttendanceModel> dataList = [];
  bool isLoading = true;
  String yyyy = '';
  String mm = '';

  Future<void> getAttendance() async {
    var currentTime = await TimeService.getCurrentTime();

    var obj = <String, String>{
      'UserCD': globals.userCD,
      'Year': currentTime.year.toString(),
      'Month': currentTime.month.toString()
    };
    String res = await api.apiCall('AttendanceApi/GetMyAttendance', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        dataList = jsonData
            .map((item) => AttendanceModel.fromJson(item))
            .toList(); // Parse the JSON data into model objects

        yyyy = currentTime.year.toString();
        mm = DateFormat.MMM().format(currentTime);
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: CupertinoListSection.insetGrouped(
              header: Text(
                'My Attendance($mm-$yyyy)',
                style: const TextStyle(fontSize: 16),
              ),
              children: dataList.map((attendance) {
                TextStyle textStyle = const TextStyle(
                  fontSize: 12, // Change this to the desired font size
                  color: Colors.black, // Change this to the desired text color
                );
                return CupertinoListTile.notched(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: attendance.status == "A"
                          ? CupertinoColors.systemRed
                          : attendance.status == "P"
                              ? CupertinoColors.systemPurple
                              : attendance.status == "W"
                                  ? Colors.lightBlue
                                  : Colors.amber,
                      borderRadius: BorderRadius.circular(
                          8.0), // Adjust the radius as needed
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                        child: Text(
                      attendance.status,
                      style: const TextStyle(color: Color.fromARGB(255, 14, 11, 11), fontSize: 12),
                    )),
                  ),
                  title: Text(
                    attendance.dayName,
                    style: textStyle,
                  ),
                  subtitle: Text(
                    attendance.workplace,
                    style: textStyle,
                  ),
                  trailing: Text(
                    "${attendance.colckIn != '' ? attendance.colckIn : "--:-- --"} | ${attendance.clockOut != '' ? attendance.clockOut : "--:-- --"}",
                    style: textStyle,
                  ),
                  onTap: () {},
                );
              }).toList(),
            ),
          );
  }
}
