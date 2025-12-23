import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:erp/model/global.dart' as globals;
import 'package:erp/common/api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:erp/model/usermodel.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Api api = Api();
  List<UserModel> dataList = [];
  String username = '';
  String dOB = '';
  String country = '';
  String email = '';
  String handPhone = '';
  String officePhone = '';
  String jobTitle = '';
  String department = '';
  String manager = '';
  String joinedDate = '';
  String company = '';
  String profilephoto = '';

  @override
  void initState() {
    super.initState();
    getUserProfle();
  }

  void getUserProfle() async {
    var obj = <String, String>{
      'UserCD': globals.userCD,
    };

    String res = await api.apiCall('EmployeeApi/GetUserProfile', obj);

    dynamic jsonData = jsonDecode(jsonDecode(res.toString()));

    if (jsonData is List) {
      setState(() {
  dataList = jsonData
      .where((e) => e != null)
      .map((e) => UserModel.fromJson(e))
      .toList();

  if (dataList.isNotEmpty) {
    final user = dataList.first;

    username = user.name ?? '';
    dOB = user.dOB ?? '';
    country = user.countryName ?? '';
    email = user.email ?? '';
    handPhone = user.mobilePh ?? '';
    officePhone = user.officePh ?? '';
    jobTitle = user.jobTitle ?? '';
    department = user.department ?? '';
    joinedDate = user.joinedDate ?? '';
    company = user.company ?? '';
    manager = user.manager ?? '';
    profilephoto = user.profilephoto ?? '';
  }
});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF136FF8),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(
                  top: 50, left: 20, right: 20, bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "My Profile",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.network(
                        globals.profilephoto,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    jobTitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            buildSection("Personal", [
              buildItem(CupertinoIcons.person, username),
              buildItem(Icons.cake, dOB),
              buildItem(Icons.location_pin, country),
            ]),
            buildSection("Contact", [
              buildItem(CupertinoIcons.mail, email),
              buildItem(Icons.phone_android, handPhone),
              buildItem(CupertinoIcons.phone, officePhone),
            ]),
            buildSection("Job", [
              buildItem(Icons.apartment, company),
              buildItem(FontAwesomeIcons.briefcase, jobTitle),
              buildItem(Icons.group, department),
              buildItem(FontAwesomeIcons.userTie, manager),
              buildItem(CupertinoIcons.calendar, joinedDate),
            ]),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String pagetitle, List<Widget> items) {
    return CupertinoListSection.insetGrouped(
      header: Text(
        pagetitle,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.black,
        ),
      ),
      backgroundColor: const Color(0xFFF0F0F0),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: items,
    );
  }
}

Widget buildItem(IconData icon, String text, {VoidCallback? onTap}) {
  return CupertinoListTile(
    leading: Icon(icon, color: CupertinoColors.black),
    title: Text(text),
    onTap: onTap,
    backgroundColor: CupertinoColors.white,
  );
}
