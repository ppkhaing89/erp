import 'dart:convert';

import 'package:erp/common/api.dart';
import 'package:erp/model/leavemodel.dart';
import 'package:erp/views/hr/calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:erp/model/global.dart' as globals;

class Leavelist extends StatefulWidget {
  const Leavelist({super.key});

  @override
  State<Leavelist> createState() => _LeavelistState();
}

class _LeavelistState extends State<Leavelist> {
  List<LeaveModel> leaveList = [];
  List<LeaveTakenModel> leaveTakenList = [];

  bool isLoading = true;
  Api api = Api();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // Top header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF136FF8),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      "Leave Application",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(Icons.notifications_none, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.network(
                      globals.profilephoto,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome back,",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  globals.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Dashboard Header =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LeaveHistoryTab()),
                            );
                          },
                        child: const Text(
                          "Leave History →",
                          style: TextStyle(
                            color: Color(0xFF136FF8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                // ===== Grid Section =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    padding: EdgeInsets.zero, // 🔥 REMOVE DEFAULT GRID PADDING
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                    children: leaveList
                        .map(
                          (leave) => LeaveCard(
                            count: leave.count,
                            total: leave.total,
                            title: leave.title,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Colleagues section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Colleague’s on leave",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Calendar()),
                    );
                  },
                  child: const Text(
                    "Full List →",
                    style: TextStyle(
                      color: Color(0xFF136FF8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Horizontal list of colleagues
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: leaveTakenList
                  .map(
                    (leave) => ColleagueCard(
                      name: leave.name,
                      leavetype: leave.leavetype,
                      leavetime: leave.leavetime,
                      profilephoto: leave.profilephoto,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF136FF8),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Apply Leave"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Leave History"),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchLeaveData();
    fetchLeaveTakenData();
  }

  void fetchLeaveData() async {
    var obj = <String, String>{
      'UserCD': globals.userCD,
    };

    String res = await api.apiCall('LeaveApi/LeaveBalanceSelect', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        leaveList = jsonData.map((item) => LeaveModel.fromJson(item)).toList();
        isLoading = false;
      });
    }
  }

  void fetchLeaveTakenData() async {
    var obj = <String, String>{
      'UserCD': globals.userCD,
    };

    String res = await api.apiCall('LeaveApi/LeaveTakenSelect', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        leaveTakenList =
            jsonData.map((item) => LeaveTakenModel.fromJson(item)).toList();
        isLoading = false;
      });
    }
  }
}


class LeaveHistoryTab extends StatelessWidget {
  const LeaveHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryCards(),
              const SizedBox(height: 20),
              // _headerRow(),
              // const SizedBox(height: 10),
              // _leaveList(),
              // const SizedBox(height: 80), // space for FAB
            ],
          ),
        ),

        // Floating Add Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 51, 111, 179),
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

Widget _summaryCards() {
  return Row(
    children: [
      _leaveSummaryCard("3/12", "Annual Leaves", const Color(0xFFE8F6F3)),
      _leaveSummaryCard("2/5", "Medical Leaves", const Color(0xFFEAF4FD)),
      _leaveSummaryCard("1/5", "Casual Leaves", const Color(0xFFFDEDE8)),
    ],
  );
}

Widget _leaveSummaryCard(String value, String label, Color bgColor) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}


Widget _headerRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        "Leave Request Info",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: "This Year",
            items: const [
              DropdownMenuItem(
                value: "This Year",
                child: Text("This Year"),
              ),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    ],
  );
}

Widget _leaveList() {
  final leaveData = [
    _LeaveItem("08 Jan, 19", "10 Jan, 19", "Approved"),
    _LeaveItem("10 Feb, 19", "12 Feb, 19", "Rejected"),
    _LeaveItem("08 May, 19", "08 May, 19", "Pending"),
    _LeaveItem("13 Jul, 19", "14 Jul, 19", "Pending"),
    _LeaveItem("02 Sep, 19", "02 Sep, 19", "Pending"),
  ];

  return Column(
    children: leaveData.map((e) => _leaveRow(e)).toList(),
  );
}

Widget _leaveRow(_LeaveItem item) {
  Color statusColor;

  switch (item.status) {
    case "Approved":
      statusColor = Colors.green;
      break;
    case "Rejected":
      statusColor = Colors.red;
      break;
    default:
      statusColor = Colors.orange;
  }

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade200),
      ),
    ),
    child: Row(
      children: [
        Expanded(child: Text(item.from)),
        Expanded(child: Text(item.to)),
        Expanded(
          child: Text(
            item.status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Icon(Icons.more_vert, size: 18),
      ],
    ),
  );
}

class _LeaveItem {
  final String from;
  final String to;
  final String status;

  _LeaveItem(this.from, this.to, this.status);
}


IconData _getLeaveIcon(String title) {
  switch (title.toLowerCase()) {
    case 'annual':
      return FontAwesomeIcons.suitcaseRolling;
    case 'medical':
      return FontAwesomeIcons.briefcaseMedical;
    case 'hospitalization':
      return FontAwesomeIcons.hospital;
    case 'compassionate':
      return FontAwesomeIcons.handHoldingHeart;
    case 'marriage':
      return FontAwesomeIcons.ring;
    case 'maternity':
      return FontAwesomeIcons.personPregnant;
    case 'paternity':
      return FontAwesomeIcons.baby;
    case 'childcare':
      return FontAwesomeIcons.babyCarriage;
    case 'reservist':
      return FontAwesomeIcons.personMilitaryPointing;
    default:
      return FontAwesomeIcons.calendar;
  }
}

class LeaveCard extends StatelessWidget {
  final String count;
  final String total;
  final String title;

  const LeaveCard({
    super.key,
    required this.count,
    required this.total,
    required this.title,
  });

  String formatLeave(String value) {
    if (value.trim().isEmpty) return '0';

    final num parsed = num.tryParse(value) ?? 0;

    // if value is 0 or 0.0 or 00
    if (parsed == 0) return '0';

    // integer (12, 07, 12.0)
    if (parsed % 1 == 0) {
      return parsed.toInt().toString();
    }

    // decimal (12.5)
    return parsed.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // 🔥 controls shadow depth
      margin: const EdgeInsets.all(3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            // Top-left icon (slightly lower)
            Row(
              children: [
                Container(
                  alignment: const Alignment(-1, -0.9),
                  child: FaIcon(
                    _getLeaveIcon(title),
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            // Center number (slightly above center)

            Row(
              children: [
                Container(
                  alignment: const Alignment(-1, -0.9),
                  child: FaIcon(
                    _getLeaveIcon(title),
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            Align(
              alignment: const Alignment(0, -0.1),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: formatLeave(count),
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "/${formatLeave(total)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-left title (slightly higher)
            Align(
              alignment: const Alignment(-1, 0.85),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 34, 34, 34),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColleagueCard extends StatelessWidget {
  final String name;
  final String leavetype;
  final String leavetime;
  final String profilephoto;

  const ColleagueCard(
      {super.key,
      required this.name,
      required this.leavetype,
      required this.leavetime,
      required this.profilephoto});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 104, 160, 244),
              Color.fromARGB(255, 19, 111, 248),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.network(
                  profilephoto,
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$leavetime\n$leavetype',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
