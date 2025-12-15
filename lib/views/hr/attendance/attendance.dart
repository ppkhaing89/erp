import 'dart:convert';
import 'package:erp/common/api.dart';
import 'package:erp/common/message.dart';
import 'package:erp/common/timeservice.dart';
import 'package:erp/model/attendancemodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:erp/model/global.dart' as globals;
import 'dart:io';
import 'package:erp/common/function.dart';
import 'package:url_launcher/url_launcher.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

String today = DateFormat('EEE d MMM yyyy').format(DateTime.now());

class _AttendanceState extends State<Attendance> {
  final ImagePicker _picker = ImagePicker();
  Api api = Api();
  Message msg = Message();
  CommonFunction cf = CommonFunction();
  String selectedWorkplace = 'Office'; // Initial value
  String _filePath = '';
  String _fileName = '';
  String _fileExt = '';
  List<AttendanceModel> dataList = [];
  List<AttendanceModel> attdataList = [];
  bool isClockedIn = false;
  bool isClockedOut = false;
  bool isLoading = true;
  String clockinTime = '';
  String clockoutTime = '';
  String checkingtime = '';
  String workinghr = '';
  String checkinlocation = '';
  String checkoutlocation = '';
  String locationtype = '';
  String remark = '';
  int present = 0;
  int absent = 0;
  int holiday = 0;
  int selectedIndex = 0;
  bool remarktextbox = false;
  int navindex = 0;
  String yyyy = '';
  String mm = '';
  int selectedyear = DateTime.now().year;
  int selectedmonth = DateTime.now().month;
  String locationMessage = "Current location unknown";
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
  final TextEditingController txtremark = TextEditingController();
  Image? imageWidget;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getAttendance();
  }

  Future<Map<String, dynamic>> getExactLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if GPS is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        "error": "GPS is disabled",
      };
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {"error": "Permission denied"};
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {"error": "Location permission permanently denied"};
    }

    // Get current GPS coordinates
    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    // Reverse geocoding → get city name
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placeMarks.first;

    return {
      "city": place.locality ?? "",
      "timeZone": DateTime.now().timeZoneName,
      "location": "${position.latitude},${position.longitude}"
    };
  }

  void onTabTapped(int index) {
    setState(() {
      if (index == 1) {
        isLoading = true;
        getAttendanceList();
      }
      navindex = index;
    });
  }

  // #region Data Access Layer
  Future<void> getAttendance() async {
    var obj = <String, String>{
      'UserCD': globals.userCD,
    };
    String res = await api.apiCall('AttendanceApi/AttendanceUserSelect', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        dataList =
            jsonData.map((item) => AttendanceModel.fromJson(item)).toList();

        if (dataList.isNotEmpty) {
          clockinTime = dataList[0].colckIn;
          clockoutTime = dataList[0].clockOut;
          checkingtime = dataList[0].checkingtime;
          workinghr = dataList[0].workinghour;
          present = dataList[0].present;
          absent = dataList[0].absent;
          holiday = dataList[0].holiday;
          checkinlocation = dataList[0].checkinlocation;
          checkoutlocation = dataList[0].checkoutlocation;
          locationtype = dataList[0].workplace;
          if (dataList[0].colckIn != '' && dataList[0].colckIn != '--:--') {
            isClockedIn = true;
          }

          if (dataList[0].clockOut != '' && dataList[0].clockOut != '--:--') {
            isClockedOut = true;
          }

          if (dataList[0].clockOut != '' && dataList[0].colckIn != '') {
            remarktextbox = true;
          }

          selectedWorkplace = dataList[0].workplace;
          txtremark.text = dataList[0].remarks;

          _filePath = dataList[0].filepath;
          _fileName = dataList[0].filename;
          _fileExt = dataList[0].fileext;
        }

        isLoading = false;
        getImage();
      });
    }
  }

  Future<void> getImage() async {
    try {
      final response = await http.get(Uri.parse(_filePath));
      if (response.statusCode == 200) {
        imageWidget = Image.memory(
          response.bodyBytes,
        );
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = "Location services are disabled.";
      });
      return;
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Location permission denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = "Location permissions are permanently denied.";
      });
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high);

    // Get placemarks (city/state)
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];

    setState(() {
      //locationMessage ="Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      locationMessage = "${place.locality}, ${place.administrativeArea}";
    });
  }

  Future<void> getAttendanceList() async {
    var currentTime = await TimeService.getCurrentTime();
    var obj = <String, String>{
      'UserCD': globals.userCD,
      'Year': selectedyear.toString(),
      'Month': selectedmonth.toString()
    };

    String res = await api.apiCall('AttendanceApi/GetMyAttendance', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        attdataList =
            jsonData.map((item) => AttendanceModel.fromJson(item)).toList();
        yyyy = currentTime.year.toString();
        mm = DateFormat.MMM().format(currentTime);
        isLoading = false;
      });
    }
  }
  // #endregion

  // #region Click Event
  Future<void> clockInClick() async {
    setState(() {
      isLoading = true;
    });

    if (selectedWorkplace == 'Home' && _filePath == '') {
      msg.showErrorDialog(context, 'Please upload WFH document.');
      return;
    }

    var currentTime = await TimeService.getCurrentTime();
    var ip = await cf.getIPAddress();
    final cityAndTimeZone = await getExactLocation();

    final city = cityAndTimeZone['city'];
    final timeZone = cityAndTimeZone['timeZone'];
    final location = cityAndTimeZone['location'];

    var clockInTime = "${currentTime.hour}:${currentTime.minute}";
    var wfhFileBytes = '';

    if (_filePath != '') {
      wfhFileBytes = base64Encode(await File(_filePath).readAsBytes());
    }

    var obj = <String, dynamic>{
      'UpdatedDate':
          "${currentTime.year}-${currentTime.month}-${currentTime.day}",
      'UserCD': globals.userCD,
      'WorkPlace': selectedWorkplace,
      'TimeZone': timeZone,
      'IPAddress': ip,
      'CityName': city,
      'Location': location,
      'ClockInTime': clockInTime,
      'OriginalFileName': _fileName,
      'FileExtension': _fileExt,
      'WFHFile': wfhFileBytes,
    };

    String body = await api.apiCall('AttendanceApi/ClockIn', obj);
    dynamic jsonObject = jsonDecode(jsonDecode(body.toString()));

    if (jsonObject.length > 0) {
      if (jsonObject[0]["MessageID"] == "I001") {
        setState(() {
          isClockedIn = true;
          getAttendance();
          isLoading = false;
        });
        if (mounted) {
          msg.showSuccessDialog(context, 'Clock In Successfully');
        }
      } else {
        if (mounted) {
          msg.showErrorDialog(context, 'Clock In Failed!');
        }
      }
    } else {
      if (mounted) {
        msg.showErrorDialog(context, 'Clock In Failed!');
      }
    }
  }

  Future<void> openMap(String coordinates) async {
    final Uri uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$coordinates');

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the map app.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening map: $e')),
      );
    }
  }

  Future<void> clockOutClick() async {
    setState(() {
      isLoading = true;
    });

    var currentTime = await TimeService.getCurrentTime();
    final cityAndTimeZone = await getExactLocation();
    final location = cityAndTimeZone['location'];

    var obj = <String, String>{
      'UpdatedDate':
          "${currentTime.year}-${currentTime.month}-${currentTime.day}",
      'UserCD': globals.userCD,
      'WorkPlace': selectedWorkplace,
      'ClockOutTime': "${currentTime.hour}:${currentTime.minute}",
      'Remarks': txtremark.text,
      "Location": location,
    };

    String body = await api.apiCall('AttendanceApi/ClockOut', obj);
    dynamic jsonObject = jsonDecode(jsonDecode(body.toString()));
    if (jsonObject.length > 0) {
      if (mounted) {
        if (jsonObject[0]["MessageID"] == "I001") {
          if (mounted) {
            msg.showSuccessDialog(context, 'Clock Out Successfully');
          }

          setState(() {
            isClockedOut = true;
            getAttendance();
            isLoading = false;
          });
        } else {
          msg.showErrorDialog(context, 'Clock Out Failed!');
        }
      }
    } else {
      if (mounted) {
        msg.showErrorDialog(context, 'Clock Out Failed!');
      }
    }
  }
  // #endregion

  // #region Controller
  Widget buildOption(String title, IconData icon) {
    bool isSelected = selectedWorkplace == title;

    return GestureDetector(
      onTap: () {
        if (checkingtime == '--:--:--') {
          setState(() {
            selectedWorkplace = title;
          });
        }
        // Optional: you can show a message if checkingtime is empty
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Choice is available only the first time!")),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
      onConfirm: (dateTime, List<int> index) async {
        setState(() {
          selectedyear = dateTime.year;
          selectedmonth = dateTime.month;
          isLoading = true; // optional
        });

        await getAttendanceList(); // wait for data

        setState(() {
          isLoading = false; // optional
        });
      },
    );
  }
  // #endregion

  @override
  Widget build(BuildContext context) {
    String buttonText = '';
    Color buttonColor = Colors.blue;
    VoidCallback? onbuttonTap;

    if (!isClockedIn) {
      buttonText = 'Clock-in';
      buttonColor = const Color.fromARGB(255, 8, 131, 13);
      onbuttonTap = () {
        msg.showConfirmDialog(
            context, 'Do you really want to proceed?', clockInClick);
      };
    } else if (isClockedIn && !isClockedOut) {
      buttonText = 'Clock-out';
      buttonColor = const Color.fromARGB(255, 239, 90, 110);
      onbuttonTap = () {
        msg.showConfirmDialog(
            context, 'Do you really want to proceed?', clockOutClick);
      };
    } else {
      buttonText = 'Clock-out';
      buttonColor = const Color.fromARGB(255, 137, 133, 133);
      onbuttonTap = () {};
    }

    void viewFile() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("View File: $_fileName"),
          content: _fileExt == 'png' || _fileExt == 'jpg' || _fileExt == 'jpeg'
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    if (_fileExt == 'png' ||
                        _fileExt == 'jpg' ||
                        _fileExt == 'jpeg')
                      CupertinoApp(
                        home: CupertinoPageScaffold(
                          child: SizedBox(
                            child: imageWidget ?? Image.file(File(_filePath)),
                          ),
                        ),
                      )
                  ],
                )
              : const Text("Cannot preview this file type."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    }

    Widget buildFileView() {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    _fileExt == 'png' || _fileExt == 'jpg' || _fileExt == 'jpeg'
                        ? (imageWidget ??
                            Image.file(File(_filePath), fit: BoxFit.cover))
                        : const Icon(Icons.insert_drive_file,
                            size: 35, color: Colors.grey),
              ),

              const SizedBox(width: 14),

              // FILE NAME TEXT
              Expanded(
                child: Text(
                  _fileName.isEmpty ? "There is no file uploaded." : _fileName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // VIEW BUTTON
              IconButton(
                icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                onPressed: viewFile,
              ),
            ],
          ),
        ),
      );
    }

    Widget locationTile({
      required String title,
      required String checkInCoordinates, // "lat,lng"
      required String checkOutCoordinates, // "lat,lng"
    }) {
      // Function to launch Google Maps with coordinates
      void openMap(String coordinates) async {
        final url =
            'https://www.google.com/maps/search/?api=1&query=$coordinates';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          throw 'Could not open the map.';
        }
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => openMap(checkInCoordinates),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 64, 61, 238),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Check-in Location'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => openMap(checkOutCoordinates),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 225, 227, 50),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Check-out Location'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    void showFileReviewDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Review File"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("File Name: $_fileName"),
              const SizedBox(height: 10),
              if (_fileExt == 'png' || _fileExt == 'jpg' || _fileExt == 'jpeg')
                CupertinoApp(
                  home: CupertinoPageScaffold(
                    child: SizedBox(
                      child: Image.file(File(_filePath)),
                    ),
                  ),
                ) // Sh
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  buildFileView(); // add widget dynamically
                });
                Navigator.pop(context); // close dialog after upload
              },
              child: const Text("Upload"),
            ),
          ],
        ),
      );
    }

    void pickFile() async {
      XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File file = File(pickedFile.path);

        _filePath = file.path;
        _fileName = file.uri.pathSegments.last;
        _fileExt = _fileName.split('.').last;

        showFileReviewDialog();
      }
    }

    Color getStatusColor(String status) {
      if (status == "H") {
        return const Color.fromARGB(255, 219, 203, 29);
      } else if (status == "W") {
        return const Color.fromARGB(255, 130, 131, 133);
      } else if (status == "A") {
        return const Color.fromARGB(255, 230, 107, 98);
      } else {
        return const Color.fromARGB(255, 68, 181, 4);
      }
    }

    String getShowText(String status, String description) {
      if (status == "H" || status == "L") {
        return description;
      } else if (status == "W") {
        return "Off Day";
      } else {
        return "ABSENT";
      }
    }

    Widget tabAttendanceList() {
      return Column(
        children: [
          SafeArea(
            child: Container(
              color: const Color(0xFF136FF8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Attendance History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 🔹 Month selector
                  InkWell(
                    onTap: () => showMonthYearPicker(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // make selector stand out
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            "${monthAbbreviations[selectedmonth - 1]} $selectedyear",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down,
                              color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  attdataList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "No attendance data available",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : Column(
                          children: attdataList.map((attendance) {
                            bool isWeekend = attendance.status == "W" ||
                                attendance.status == "H" ||
                                attendance.status == "L" ||
                                attendance.status == "A";

                            if (isWeekend) {
                              return Container(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          attendance.dayName.toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                        ),
                                        Text(
                                          attendance.attDate,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            getStatusColor(attendance.status),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        getShowText(attendance.status,
                                            attendance.description),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: attendance.status == "H"
                                                ? Colors.black
                                                : Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Normal Working Day UI
                            return Container(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        attendance.dayName.toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue),
                                      ),
                                      Text(
                                        attendance.attDate,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.login,
                                              color: Colors.green, size: 20),
                                          const SizedBox(width: 6),
                                          Text(
                                            attendance.colckIn.isNotEmpty
                                                ? attendance.colckIn
                                                : "--:--",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.logout,
                                              color: Colors.red, size: 20),
                                          const SizedBox(width: 6),
                                          Text(
                                            attendance.clockOut.isNotEmpty
                                                ? attendance.clockOut
                                                : "--:--",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Check-in Map
                                      GestureDetector(
                                        onTap: () => openMap(
                                          attendance.checkinlocation,
                                        ),
                                        child: Row(
                                          children: [
                                            (attendance.checkinlocation ==
                                                        "NULL" ||
                                                    attendance.checkinlocation
                                                        .isEmpty)
                                                ? const SizedBox.shrink()
                                                : const Icon(Icons.location_on,
                                                    size: 16,
                                                    color: Color.fromARGB(
                                                        255, 243, 27, 139)),
                                            const SizedBox(width: 4),
                                            Text(
                                              (attendance.checkinlocation ==
                                                          "NULL" ||
                                                      attendance.checkinlocation
                                                          .isEmpty)
                                                  ? ""
                                                  : "View map",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color.fromARGB(
                                                    255, 243, 27, 139),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Check-out Map
                                      GestureDetector(
                                        onTap: () => openMap(
                                          attendance.checkoutlocation,
                                        ),
                                        child: Row(
                                          children: [
                                            (attendance.checkoutlocation ==
                                                        "NULL" ||
                                                    attendance.checkoutlocation
                                                        .isEmpty)
                                                ? const SizedBox.shrink()
                                                : const Icon(Icons.location_on,
                                                    size: 16,
                                                    color: Color.fromARGB(
                                                        255, 118, 59, 255)),
                                            const SizedBox(width: 4),
                                            Text(
                                              (attendance.checkoutlocation ==
                                                          "NULL" ||
                                                      attendance
                                                          .checkoutlocation
                                                          .isEmpty)
                                                  ? ""
                                                  : "View map",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color.fromARGB(
                                                    255, 118, 59, 255),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "${attendance.workplace} | ${attendance.workinghour}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Future<Widget> tabAttendance() async {
      return Stack(
        children: [
          Container(
            height: 250,
            color: const Color.fromARGB(255, 10, 97, 248),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // 🔹 Top Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // 🔹 Goes back to the previous screen
                                  },
                                ),
                                const Icon(Icons.location_on,
                                    color: Colors.white),
                                const SizedBox(width: 4),
                                Text(locationMessage,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 🔹 Workplace + Shift Info + Check In
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Workplace Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildOption("Home", Icons.home),
                                  const SizedBox(width: 8),
                                  buildOption("Office", Icons.business),
                                  const SizedBox(width: 8),
                                  buildOption("Onsite", Icons.location_on),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // 🔹 Shift Info
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 104, 206, 246),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    today,
                                    //"GENERAL SHIFT",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 74, 79, 74),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 🔹 Time + Check In Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    checkingtime,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 10),
                                    ),
                                    onPressed: () => onbuttonTap!(),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.clock_solid,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          buttonText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              const Divider(color: Colors.grey, thickness: 0.5),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TimeInfo(
                                      title: "Check In", time: clockinTime),
                                  TimeInfo(
                                      title: "Check Out", time: clockoutTime),
                                  TimeInfo(
                                      title: "Working HR's", time: workinghr),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(children: [
                          Expanded(
                              child: Column(
                            children: [
                              locationTile(
                                title: 'Check-in/out Location',
                                checkInCoordinates: checkinlocation,
                                checkOutCoordinates: checkoutlocation,
                              ),
                            ],
                          ))
                        ]),

                        const SizedBox(height: 16),

                        // 🔹 WFH Approval + Upload
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "WFH Approval Document",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(FontAwesomeIcons.upload,
                                  color: Colors.white),
                              label: const Text(
                                'Upload File',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: (checkingtime == '--:--:--')
                                  ? pickFile
                                  : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        buildFileView(),

                        const SizedBox(height: 20),

                        // 🔹 Attendance summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Attendance for this Month",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 193, 216, 233),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: Color.fromARGB(255, 75, 93, 107)),
                                  const SizedBox(width: 10),
                                  Text(
                                    DateFormat('MMM').format(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AttendanceCard(
                                borderColor: Colors.green,
                                title: "Present",
                                value: present),
                            AttendanceCard(
                                borderColor: Colors.red,
                                title: "Absents",
                                value: absent),
                            AttendanceCard(
                                borderColor: Colors.orange,
                                title: "Holidays",
                                value: holiday),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 232, 232),
      body: navindex == 0
          ? FutureBuilder<Widget>(
              future: tabAttendance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return const SizedBox.shrink();
              },
            )
          : tabAttendanceList(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navindex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          setState(() => navindex = index);
          if (index == 1) {
            setState(() => isLoading = true);
            await getAttendanceList();
            setState(() => isLoading = false);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userClock),
            label: 'Clock-in/out',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.clipboardUser),
            label: 'Attendance List',
          ),
        ],
      ),
    );
  }
}

// #region Stateless Widget
class TimeInfo extends StatelessWidget {
  final String title;
  final String time;
  const TimeInfo({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.access_time, color: Colors.blue),
        const SizedBox(height: 4),
        Text(time,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final Color borderColor;
  final String title;
  final int value;

  const AttendanceCard({
    super.key,
    required this.borderColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),

            // 🔹 Card content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: borderColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// #endregion
