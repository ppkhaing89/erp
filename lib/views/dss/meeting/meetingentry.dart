import 'dart:convert';
import 'dart:io';

import 'package:erp/common/api.dart';
import 'package:erp/common/function.dart';
import 'package:erp/common/message.dart';
import 'package:erp/common/timeservice.dart';
import 'package:erp/customWidgets/erpbgicon.dart';
import 'package:erp/customWidgets/erpbutton.dart';
import 'package:erp/customWidgets/erpdatetimepicker.dart';
import 'package:erp/customWidgets/erpsearchbox.dart';
import 'package:erp/customWidgets/erpselectbox.dart';
import 'package:erp/customWidgets/erptextarea.dart';
import 'package:erp/customWidgets/erptextfield.dart';
import 'package:erp/model/meetingmodel.dart';
import 'package:erp/views/common/imagepreview.dart';
import 'package:erp/views/dss/meeting/meetinglist.dart';
import 'package:erp/views/dss/seaching/partnersearchlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:erp/model/global.dart' as globals;
import 'package:image_picker/image_picker.dart';

class MeetingEntry extends StatefulWidget {
  final String meetingCD;
  const MeetingEntry({super.key, required this.meetingCD});

  @override
  State<MeetingEntry> createState() => _MeetingEntryState();
}

class _MeetingEntryState extends State<MeetingEntry> {
  Api api = Api();
  Message msg = Message();
  CommonFunction cf = CommonFunction();
  final ImagePicker _picker = ImagePicker();
  List<MeetingModel> dataList = [];
  List<MeetingModel> meetingattachList = [];
  dynamic countryList = [];
  bool isLoading = true;
  int navindex = 0;
  String _filePath = '';
  String _fileName = '';
  String _fileExt = '';
  late MeetingModel meetingModel;
  final dynamic meetingStatusList = [
    {"MeetingStatus": "Schedule"},
    {"MeetingStatus": "Completed"},
    {"MeetingStatus": "Cancelled"},
    // Add more meeting objects if needed
  ];

  int selectedyear = DateTime.now().year;
  final TextEditingController txtMeetingCD = TextEditingController();
  final TextEditingController txtCountry = TextEditingController();
  final TextEditingController txtMeetingPurpose = TextEditingController();
  final TextEditingController txtPartnerName = TextEditingController();
  final TextEditingController txtAttendees = TextEditingController();
  final TextEditingController txtMeetingStatus = TextEditingController();
  final TextEditingController txtStartDate = TextEditingController();
  final TextEditingController txtEndDate = TextEditingController();
  final TextEditingController txtMeetingAgenda = TextEditingController();
  final TextEditingController txtMeetingResult = TextEditingController();
  final TextEditingController txtClockin = TextEditingController();
  final TextEditingController txtClockout = TextEditingController();
  final TextEditingController txtClockinLocation = TextEditingController();
  final TextEditingController txtClockoutLocation = TextEditingController();

  Future<void> getMeeting() async {
    var obj = <String, String>{'ScheduleCode': widget.meetingCD};
    String res = await api.apiCall('MeetingApi/GetMeeting', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        txtMeetingCD.text = jsonData[0]['MeetingCD'] ?? '';
        txtCountry.text = jsonData[0]['CountryName'] ?? '';
        txtMeetingPurpose.text = jsonData[0]['MeetingPurpose'] ?? '';
        txtPartnerName.text = jsonData[0]['PartnerName'] ?? '';
        txtAttendees.text = jsonData[0]['Attendees'] ?? '';
        txtMeetingStatus.text = jsonData[0]['MeetingStatus'] ?? '';
        txtStartDate.text = jsonData[0]['StartDate'] ?? '';
        txtEndDate.text = jsonData[0]['EndDate'] ?? '';
        txtMeetingAgenda.text = jsonData[0]['MeetingAgenda'] ?? '';
        txtMeetingResult.text = jsonData[0]['MeetingResult'] ?? '';
        txtClockin.text = jsonData[0]['CheckinTime'] ?? '';
        txtClockout.text = jsonData[0]['CheckoutTime'] ?? '';
        txtClockinLocation.text = jsonData[0]['CheckinLocation'] ?? '';
        txtClockoutLocation.text = jsonData[0]['CheckoutLocation'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          isLoading = true;
        });

        File file = File(pickedFile.path);

        _filePath = file.path;
        _fileName = file.uri.pathSegments.last;
        _fileExt = _fileName.split('.').last;

        var attFileBytes = '';

        if (_filePath != '') {
          attFileBytes = base64Encode(await File(_filePath).readAsBytes());
        }

        var obj = <String, dynamic>{
          'UserCD': globals.userCD,
          'MeetingCD': txtMeetingCD.text,
          'OriginalFileName': _fileName,
          'FileExtension': _fileExt,
          'FileType': '1',
          'AttachFile': attFileBytes,
        };

        String body = await api.apiCall('MeetingApi/UploadAttachment', obj);
        dynamic jsonObject = jsonDecode(jsonDecode(body.toString()));

        if (jsonObject.length > 0) {
          if (jsonObject[0]["MessageID"] == "I001") {
            if (mounted) {
              msg.showSuccessDialog(context, jsonObject[0]["MessageText"]);
              var v1 = await getAttachment();
              setState(() {
                meetingattachList = v1;
              });
            }
          } else {
            if (mounted) {
              msg.showErrorDialog(context, 'Upload Failed!');
            }
          }
        } else {
          if (mounted) {
            msg.showErrorDialog(context, 'Upload Failed!');
          }
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        msg.showErrorDialog(context, 'Upload Failed');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<MeetingModel>> getAttachment() async {
    var obj = <String, String>{'MeetingCD': widget.meetingCD};
    String res = await api.apiCall('MeetingApi/GetMeetingAttachment', obj);
    List<dynamic> decodedData = jsonDecode(jsonDecode(res));
    List<MeetingModel> meetingModels =
        decodedData.map((data) => MeetingModel.fromJson(data)).toList();
    meetingattachList = meetingModels;
    return meetingModels;
  }

  Future<void> getCountry() async {
    var obj = <String, String>{
      'UserCD': globals.userCD,
      'SystemCD': 'DSS',
      'CheckCountryAccess': 'true'
    };
    String res = await api.apiCall('CountryApi/GetCountry', obj);
    countryList = jsonDecode(jsonDecode(res));

    if (countryList.length > 0) {
      txtCountry.text = countryList[0]['CountryName'] ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void downloadFile(filepath) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ImagePreview(
          imageurl: filepath,
          type: 1,
        ),
      ),
    );
  }

  bool meetingErrorcheck() {
    if (txtMeetingPurpose.text.isEmpty) {
      msg.showErrorDialog(context, 'Meeting purpose is required!');
      return false;
    } else if (txtPartnerName.text.isEmpty) {
      msg.showErrorDialog(context, 'Partner name is required!');
      return false;
    } else if (txtStartDate.text.isEmpty) {
      msg.showErrorDialog(context, 'Start date is required!');
      return false;
    } else if (txtEndDate.text.isEmpty) {
      msg.showErrorDialog(context, 'End date is required!');
      return false;
    } else if (txtMeetingAgenda.text.isEmpty) {
      msg.showErrorDialog(context, 'Meeting Agenda is required!');
      return false;
    }

    return true;
  }

  void saveMeeting() async {
    if (!meetingErrorcheck()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    var c1 = countryList
        .where(
          (country) => country["CountryName"] == txtCountry.text,
        )
        .toList();

    var obj = <String, String>{
      'Mode': widget.meetingCD == '' ? 'New' : 'Edit',
      'MeetingCD': txtMeetingCD.text,
      'UserCD': globals.userCD,
      'CountryCD': c1[0]["CountryCD"],
      'Meeting_Purpose': txtMeetingPurpose.text,
      'Partner': txtPartnerName.text,
      'StartDateTime': txtStartDate.text,
      'EndDateTime': txtEndDate.text,
      'Attendees': txtAttendees.text,
      'MeetingStatus': txtMeetingStatus.text == 'Schedule'
          ? '1'
          : txtMeetingStatus.text == 'Completed'
              ? '2'
              : '9',
      'Agenda': txtMeetingAgenda.text,
      'MeetingResult': txtMeetingResult.text,
    };

    String res = await api.apiCall('MeetingApi/MeetingCUD', obj);
    var r1 = jsonDecode(jsonDecode(res));

    if (r1.length > 0) {
      if (r1[0]["MessageID"] == 'I001') {
        if (mounted) {
          msg.showSuccessDialogWithFunction(context, r1[0]["MessageText"], () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => const MeetingList(),
              ),
            );
          });
        }
      } else {
        if (mounted) {
          msg.showErrorDialog(context, r1[0]["MessageText"]);
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void partnerSearch() {
    if (txtCountry.text.isEmpty) {
      msg.showErrorDialog(context, 'Please select country.');
      return;
    }

    var c1 = countryList
        .where(
          (country) => country["CountryName"] == txtCountry.text,
        )
        .toList();

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => PartnerSeachList(
          countryCD: c1[0]["CountryCD"],
          controller: txtPartnerName,
        ),
      ),
    );
  }

  Future<void> initialize() async {
    await Future.wait([
      getCountry(),
      if (widget.meetingCD != '') getMeeting(),
      getAttachment(),
    ]);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    txtMeetingCD.dispose();
    txtCountry.dispose();
    txtMeetingPurpose.dispose();
    txtPartnerName.dispose();
    txtAttendees.dispose();
    txtMeetingStatus.dispose();
    txtStartDate.dispose();
    txtEndDate.dispose();
    txtMeetingAgenda.dispose();
    txtMeetingResult.dispose();
    txtClockin.dispose();
    txtClockout.dispose();
    txtClockinLocation.dispose();
    txtClockoutLocation.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      navindex = index;
    });
  }

  Future<void> clockin() async {
    setState(() {
      isLoading = true;
    });

    var currentTime = await TimeService.getCurrentTime();
    var ip = await cf.getIPAddress();
    final cityAndTimeZone = await cf.getCityAndTimeZone(ip);
    final location = cityAndTimeZone['location'];

    var clockInTime = "${currentTime.hour}:${currentTime.minute}";

    var obj = <String, String>{
      'Mode': 'clockinmobile',
      'MeetingCD': txtMeetingCD.text,
      'CheckinTime': clockInTime,
      'CheckinLocation': location,
    };

    String res = await api.apiCall('MeetingApi/MeetingCUD', obj);
    var r1 = jsonDecode(jsonDecode(res));

    if (r1.length > 0) {
      if (r1[0]["MessageID"] == 'I001') {
        if (mounted) {
          msg.showSuccessDialog(context, r1[0]["MessageText"]);
          setState(() {
            txtClockin.text = clockInTime;
            txtClockinLocation.text = location;
          });
        }
      } else {
        if (mounted) {
          msg.showErrorDialog(context, r1[0]["MessageText"]);
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> clockout() async {
    setState(() {
      isLoading = true;
    });

    var currentTime = await TimeService.getCurrentTime();
    var ip = await cf.getIPAddress();
    final cityAndTimeZone = await cf.getCityAndTimeZone(ip);
    final location = cityAndTimeZone['location'];

    var clockoutTime = "${currentTime.hour}:${currentTime.minute}";

    var obj = <String, String>{
      'Mode': 'clockoutmobile',
      'MeetingCD': txtMeetingCD.text,
      'CheckoutTime': clockoutTime,
      'CheckoutLocation': location,
    };

    String res = await api.apiCall('MeetingApi/MeetingCUD', obj);
    var r1 = jsonDecode(jsonDecode(res));

    if (r1.length > 0) {
      if (r1[0]["MessageID"] == 'I001') {
        if (mounted) {
          msg.showSuccessDialog(context, r1[0]["MessageText"]);
          txtClockout.text = clockoutTime;
          txtClockoutLocation.text = location;
        }
      } else {
        if (mounted) {
          msg.showErrorDialog(context, r1[0]["MessageText"]);
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            color: Colors.white, // Set the background color of the whole screen
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        : CupertinoApp(
            home: CupertinoPageScaffold(
                resizeToAvoidBottomInset: false,
                navigationBar: CupertinoNavigationBar(
                  leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(
                          context); // Navigate back to the previous page
                    },
                    child: const Icon(CupertinoIcons.back),
                  ),
                  middle: const Text('Meeting Entry'),
                  trailing: navindex == 0
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              isLoading = true;
                            });
                            saveMeeting();
                          },
                          child: Text(
                            widget.meetingCD == '' ? 'Save' : 'Update',
                            style: const TextStyle(
                                color: CupertinoColors.activeBlue),
                          ),
                        )
                      : navindex == 2
                          ? GestureDetector(
                              onTap: () {
                                _pickImageFromGallery();
                              },
                              child: const Text(
                                'Upload',
                                style: TextStyle(
                                    color: CupertinoColors.activeBlue),
                              ),
                            )
                          : null,
                ),
                child: CupertinoTabScaffold(
                    tabBar: CupertinoTabBar(
                      onTap: onTabTapped,
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.calendar_badge_plus),
                          label: 'Entry',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.placemark),
                          label: 'Check-In/Out',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.paperclip),
                          label: 'Attachment',
                        ),
                      ],
                    ),
                    tabBuilder: (BuildContext context, int index) {
                      return CupertinoTabView(builder: (BuildContext context) {
                        return CupertinoPageScaffold(
                            child: SafeArea(
                                // Use SafeArea to avoid overlap
                                child: SingleChildScrollView(
                                    child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: navindex == 0
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/meetingentry.jpg',
                                      ),
                                      const SizedBox(height: 10.0),
                                      ERPTextField(
                                        label: 'Meeting Code',
                                        controller: txtMeetingCD,
                                        disabled: true,
                                      ),
                                      const SizedBox(height: 10.0),
                                      ERPSelectBox(
                                        label: 'Country',
                                        title: 'Select Country',
                                        controller: txtCountry,
                                        value: 'CountryName',
                                        options: countryList,
                                      ),
                                      const SizedBox(height: 10.0),
                                      ERPTextField(
                                        label: 'Meeting Purpose',
                                        controller: txtMeetingPurpose,
                                        disabled: false,
                                        isRequired: true,
                                      ),
                                      const SizedBox(height: 10.0),
                                      ERPSearchBox(
                                          label: "Partner Name",
                                          controller: txtPartnerName,
                                          isRequired: true,
                                          onTap: partnerSearch),
                                      const SizedBox(height: 10.0),
                                      ERPDatetimepicker(
                                        label: "Start Date Time",
                                        controller: txtStartDate,
                                        isRequired: true,
                                      ),
                                      const SizedBox(height: 10.0),
                                      ERPDatetimepicker(
                                        label: "End Date Time",
                                        controller: txtEndDate,
                                        isRequired: true,
                                      ),
                                      const SizedBox(height: 10.0),
                                      ERPTextField(
                                        label: 'Attendees',
                                        controller: txtAttendees,
                                        disabled: false,
                                      ),
                                      const SizedBox(height: 10.0),
                                      ERPSelectBox(
                                        label: 'Meeting Status',
                                        title: 'Select Meeting Status',
                                        controller: txtMeetingStatus,
                                        value: 'MeetingStatus',
                                        options: meetingStatusList,
                                      ),
                                      const SizedBox(height: 10.0),
                                      ERPTextArea(
                                        label: 'Meeting Agenda',
                                        controller: txtMeetingAgenda,
                                        disabled: false,
                                        maxlines: 3,
                                        isRequired: true,
                                      ),
                                      const SizedBox(height: 10.0),
                                      ERPTextArea(
                                        label: 'Meeting Result',
                                        controller: txtMeetingResult,
                                        disabled: false,
                                        maxlines: 3,
                                      ),
                                      const SizedBox(height: 10.0),
                                    ],
                                  )
                                : navindex == 1
                                    ? widget.meetingCD == ''
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                                Image.asset(
                                                  'assets/images/checkin.jpg',
                                                ),
                                                const SizedBox(height: 30.0),
                                                const Center(
                                                    child: Text(
                                                  'Please save the meeting first.',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ))
                                              ])
                                        : isLoading
                                            ? Container(
                                                color: Colors
                                                    .white, // Set the background color of the whole screen
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/checkin.jpg',
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  ERPTextField(
                                                    label: 'Check-in Time',
                                                    controller: txtClockin,
                                                    disabled: true,
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  ERPTextField(
                                                    label: 'Check-in Location',
                                                    controller:
                                                        txtClockinLocation,
                                                    disabled: true,
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  ERPTextField(
                                                    label: 'Check-out Time',
                                                    controller: txtClockout,
                                                    disabled: true,
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  ERPTextField(
                                                    label: 'Check-in Location',
                                                    controller:
                                                        txtClockoutLocation,
                                                    disabled: true,
                                                  ),
                                                  const SizedBox(height: 20.0),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ERPButton(
                                                          text: 'Check-in',
                                                          icon: CupertinoIcons
                                                              .location_circle,
                                                          onPressed: txtClockin
                                                                  .text.isEmpty
                                                              ? () {
                                                                  msg.showConfirmDialog(
                                                                      context,
                                                                      'Do you really want to proceed?',
                                                                      clockin);
                                                                }
                                                              : null,
                                                          color: CupertinoColors
                                                              .activeGreen),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      ERPButton(
                                                          text: 'Check-out',
                                                          icon: CupertinoIcons
                                                              .location_circle,
                                                          onPressed: txtClockout
                                                                  .text.isEmpty
                                                              ? () {
                                                                  msg.showConfirmDialog(
                                                                      context,
                                                                      'Do you really want to proceed?',
                                                                      clockout);
                                                                }
                                                              : null,
                                                          color: CupertinoColors
                                                              .systemRed),
                                                    ],
                                                  ),
                                                ],
                                              )
                                    : isLoading
                                        ? Container(
                                            color: Colors
                                                .white, // Set the background color of the whole screen
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              Image.asset(
                                                'assets/images/upload.jpg',
                                              ),
                                              CupertinoListSection.insetGrouped(
                                                header: const Text(
                                                  'Uploaded File List',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                children: meetingattachList
                                                        .isEmpty
                                                    ? [
                                                        const CupertinoListTile(
                                                          title: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16.0),
                                                            child: Center(
                                                              child: Text(
                                                                'There is no data to display !',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                    : meetingattachList
                                                        .map((attach) {
                                                        TextStyle textStyle =
                                                            const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                        );
                                                        return CupertinoListTile
                                                            .notched(
                                                          leading: erpBGIcon(
                                                            icon: const Icon(
                                                              Icons.file_copy,
                                                              color:
                                                                  CupertinoColors
                                                                      .white,
                                                            ),
                                                            backgroundcolor:
                                                                CupertinoColors
                                                                    .systemPink,
                                                          ),
                                                          title: Text(
                                                            attach.fileName,
                                                            style: textStyle,
                                                          ),
                                                          subtitle: Text(
                                                            attach.fileType,
                                                            style: textStyle,
                                                          ),
                                                          trailing: const Icon(
                                                              Icons.download),
                                                          onTap: () {
                                                            setState(() {
                                                              downloadFile(attach
                                                                  .filePath);
                                                            });
                                                          },
                                                        );
                                                      }).toList(),
                                              ),
                                            ],
                                          ),
                          ),
                        ))));
                      });
                    })));
  }
}
