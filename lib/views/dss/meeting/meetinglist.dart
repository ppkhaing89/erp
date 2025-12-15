import 'dart:convert';
import 'package:erp/common/api.dart';
import 'package:erp/model/meetingmodel.dart';
import 'package:erp/views/dss/meeting/meetingentry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:erp/model/global.dart' as globals;
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';

class MeetingList extends StatefulWidget {
  const MeetingList({super.key});

  @override
  State<MeetingList> createState() => _MeetingListState();
}

class _MeetingListState extends State<MeetingList> {
  Api api = Api();
  List<MeetingModel> dataList = [];
  bool isLoading = true;
  int selectedyear = DateTime.now().year;
  int selectedmonth = DateTime.now().month;
  final List<String> monthAbbreviations = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  Future<void> getMeeting() async {
    var obj = <String, String>{
      'AccountManagerCD': globals.userCD,
      'Year': selectedyear.toString(),
      'Month': selectedmonth.toString()
    };
    String res = await api.apiCall('MeetingApi/GetMeeting', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        dataList = jsonData
            .map((item) => MeetingModel.fromJson(item))
            .toList(); // Parse the JSON data into model objects

        isLoading = false;
      });
    }
  }

  void showMonthYearPicker(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      pickerTheme: const DateTimePickerTheme(
        showTitle: true,
        confirm: Text('Done', style: TextStyle(color: Colors.blue)),
        cancel: Text('Cancel', style: TextStyle(color: Colors.red)),
      ),
      minDateTime: DateTime(2000),
      maxDateTime: DateTime(2100),
      initialDateTime: DateTime.now(),
      dateFormat: 'MMM yyyy',
      locale: DateTimePickerLocale.en_us,
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          selectedyear = dateTime.year;
          selectedmonth = dateTime.month;
          getMeeting();
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    selectedyear = DateTime.now().year;
    selectedmonth = DateTime.now().month;
    getMeeting();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            resizeToAvoidBottomInset: false,
            navigationBar: CupertinoNavigationBar(
              middle: const Text('DSS - Meeting List'),
              trailing: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const MeetingEntry(
                        meetingCD: '',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: CupertinoColors.activeBlue),
                ),
              ),
            ),
            child: SafeArea(
                child: SingleChildScrollView(
                    child: Column(
              children: [
                Image.asset(
                  'assets/images/meeting.jpg',
                ),
                CupertinoListSection.insetGrouped(
                  margin: const EdgeInsets.all(10.0),
                  dividerMargin: 0,
                  header: const Text(
                    'Filter By',
                    style: TextStyle(fontSize: 16),
                  ),
                  children: [
                    CupertinoListTile.notched(
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust the radius as needed
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(
                            child: Icon(
                          CupertinoIcons.calendar_circle,
                          color: Colors.white,
                        )),
                      ),
                      title: const Text(
                        'Meeting Date',
                        style: (TextStyle(fontSize: 14)),
                      ),
                      additionalInfo: Text(
                          '${monthAbbreviations[selectedmonth - 1]} $selectedyear',
                          style: const TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      trailing: const Icon(
                        CupertinoIcons.arrowtriangle_down_fill,
                        size: 13,
                        color: CupertinoColors.systemBlue,
                      ),
                      onTap: () {
                        showMonthYearPicker(context);
                      },
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  margin: const EdgeInsets.all(10.0),
                  dividerMargin: 0,
                  children: dataList.isEmpty
                      ? [
                          const CupertinoListTile(
                            title: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'There is no data to display !',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]
                      : dataList.map((meeting) {
                          TextStyle textStyle = const TextStyle(
                            fontSize:
                                12, // Change this to the desired font size
                            color: Colors
                                .black, // Change this to the desired text color
                          );
                          return CupertinoListTile.notched(
                            leading: Container(
                              decoration: BoxDecoration(
                                color: meeting.meetingStatus == "Completed"
                                    ? CupertinoColors.activeGreen
                                    : meeting.meetingStatus == "Cancelled"
                                        ? CupertinoColors.systemRed
                                        : Colors.lightBlue,
                                borderRadius: BorderRadius.circular(
                                    8.0), // Adjust the radius as needed
                              ),
                              width: double.infinity,
                              height: double.infinity,
                              child: Center(
                                  child: Icon(
                                meeting.meetingStatus == "Schedule"
                                    ? CupertinoIcons.calendar_circle
                                    : meeting.meetingStatus == "Completed"
                                        ? CupertinoIcons.check_mark_circled
                                        : CupertinoIcons.multiply_circle,
                                color: Colors.white,
                              )),
                            ),
                            title: Text(
                              "${meeting.meetingPurpose} | ${meeting.partnerName}",
                              style: textStyle,
                            ),
                            subtitle: Text(
                              "${meeting.startDate} ~ ${meeting.endDate}",
                              style: textStyle,
                            ),
                            trailing: const Icon(CupertinoIcons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => MeetingEntry(
                                      meetingCD: meeting.meetingCD),
                                ),
                              );
                            },
                          );
                        }).toList(),
                ),
              ],
            ))));
  }
}
