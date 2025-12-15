import 'package:erp/common/function.dart';
import 'package:erp/views/dss/dssmenulist.dart';
import 'package:erp/views/home/login.dart';
import 'package:erp/views/hr/hrmenulist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:erp/common/message.dart';
import 'package:erp/common/api.dart';
import 'package:erp/model/global.dart' as globals;
import 'package:erp/model/systemmodel.dart';
import 'dart:convert';

class ModuleList extends StatefulWidget {
  const ModuleList({super.key});

  @override
  State<ModuleList> createState() => _ModuleListState();
}

class _ModuleListState extends State<ModuleList> {
  Api api = Api();
  Message msg = Message();
  List<SystemModel> dataList = [];
  String username = globals.userName;
  int? hoveredIndex;
  bool isTapped = false;

  @override
  void initState() {
    super.initState();
    getSystemList();
  }

  void menuClick(menu) {
    switch (menu) {
      case 'VPPA':
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const DSSMenuList(),
          ),
        );
        break;
      case 'HR':
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const HRMenuList(),
          ),
        );
        break;
      case 'DSS':
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const DSSMenuList(),
          ),
        );
        break;
    }
  }

  Future<void> getSystemList() async {
    var obj = <String, String>{
      'UserCD': globals.userCD,
    };

    String res = await api.apiCall('UserApi/SystemSelect', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        dataList = jsonData.map((item) => SystemModel.fromJson(item)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
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
                      "D-Link ERP System",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.power_settings_new,
                          color: Colors.white),
                      onPressed: () {
                        CommonFunction cf = CommonFunction();
                        cf.clearGlobals();
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                    ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 16.0, bottom: 0, left: 0),
                          child: Text(
                            'Module List',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              child: GridView.builder(
                                padding: const EdgeInsets.only(top: 20),
                                itemCount: dataList.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.1,
                                  mainAxisSpacing: 3,
                                  crossAxisSpacing: 3,
                                ),
                                itemBuilder: (context, index) {
                                  final isHovered = hoveredIndex == index;
                                  List.filled(dataList.length, false);
                                  return CupertinoButton(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    onPressed: () {
                                      menuClick(dataList[index].systemCD);
                                    },
                                    child: Card(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      shadowColor: Colors.black54,
                                      elevation: 7,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.asset(
                                            'assets/images/${dataList[index].mobileIcon}',
                                            width: 100,
                                            height: 50,
                                          ),
                                          MouseRegion(
                                            onEnter: (_) {
                                              setState(() {
                                                hoveredIndex = index;
                                              });
                                            },
                                            onExit: (_) {
                                              setState(() {
                                                hoveredIndex = null;
                                              });
                                            },
                                            child: Text(
                                              dataList[index].systemCD,
                                              style: TextStyle(
                                                color: isHovered
                                                    ? Colors.blue
                                                    : Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
