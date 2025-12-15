import 'dart:convert';
import 'package:erp/views/home/modulelist.dart';
import 'package:erp/views/hr/attendance/attendance.dart';
import 'package:erp/views/hr/calendar/calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:erp/model/global.dart' as globals;
import 'package:erp/views/home/profile.dart';
import 'package:erp/common/api.dart';
import 'package:erp/model/menumodel.dart';

class HRMenuList extends StatefulWidget {
  const HRMenuList({super.key});

  @override
  State<HRMenuList> createState() => _HRMenuListState();
}

IconData getIconFromName(String name) {
  const iconMap = {
    'attendance': FontAwesomeIcons.clock,
    'activities': FontAwesomeIcons.clipboardList,
    'calendar': Icons.calendar_month,
    'faq': Icons.help_outline,
    'px': Icons.language_outlined,
    'forms': Icons.description_outlined,
  };
  return iconMap[name] ?? Icons.help_outline;
}

final Map<String, Widget> routeMap = {
  'My Attendance': const Attendance(),
  'Calendar': const Calendar(),
};

class _ExpandableSection extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final List<ExpandableChild> children;

  const _ExpandableSection({
    required this.title,
    this.leadingIcon = Icons.public,
    this.children = const [],
  });

  void navigateToRoute(
      BuildContext context, String routeName, Map<String, Widget> routeMap) {
    final page = routeMap[routeName];

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      // Optional: show a message if route is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route not found: $routeName')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding:
              const EdgeInsets.only(left: 54, right: 12, bottom: 8),
          leading: Icon(leadingIcon, color: Colors.blue),
          title: Text(title, style: textStyle),
          backgroundColor: const Color(0xFFF6F7FB),
          collapsedBackgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          children: children.map((child) {
            return _BulletItem(
              child.name,
              onTap: () {
                navigateToRoute(context, child.route, routeMap);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ExpandableChild extends StatelessWidget {
  final String name;
  final String route;

  const ExpandableChild(this.name, this.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final VoidCallback? onTap; // 🔹 optional onTap
  const _BulletItem(this.text, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // ✅ adds ripple effect
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.circle, size: 6),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final String routename;
  const _MenuTile(
      {required this.icon,
      required this.title,
      required this.trailing,
      required this.routename});

  @override
  Widget build(BuildContext context) {
    final border =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: const Color.fromARGB(255, 255, 255, 255),
        shape: border,
        child: ListTile(
          dense: false,
          shape: border,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 13.0), // <-- reduce default padding
          leading: Icon(icon, color: Colors.blue),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          trailing: trailing ?? const SizedBox.shrink(),
          onTap: () {
            final widget = routeMap[routename];
            if (widget != null) {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => widget),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Page not found: $routename')),
              );
            }
          },
        ),
      ),
    );
  }
}

class _HRMenuListState extends State<HRMenuList> {
  int selectedIndex = -1;
  int tabindex = 0;
  bool isSocialNewsExpanded = true;
  List<MenuModel> dataList = [];
  late List<MenuModel> menuTree = [];
  late List<MenuModel> originalMenuTree = [];
  Api api = Api();

  @override
  void initState() {
    super.initState();
    getMenuList();
  }

  void getMenuList() async {
    var obj = <String, String>{
      'UserCD': globals.userCD,
      'CurrentSystemCD': 'HR',
    };

    String res = await api.apiCall('UserApi/MenuSelect', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        dataList = jsonData.map((item) => MenuModel.fromJson(item)).toList();
        menuTree = buildMenuHierarchy(dataList);
        originalMenuTree = menuTree; // ✅ keep a copy for filtering
      });
    }
  }

  void _filterMenu(String query) {
    setState(() {
      menuTree = _filterMenuRecursive(originalMenuTree, query.toLowerCase());
    });
  }

  List<MenuModel> _filterMenuRecursive(List<MenuModel> items, String query) {
    List<MenuModel> filtered = [];

    for (var item in items) {
      // Check if this item matches
      final matchesSelf = item.menuName.toLowerCase().contains(query);

      // Recursively filter children
      final filteredChildren = _filterMenuRecursive(item.children, query);

      if (matchesSelf || filteredChildren.isNotEmpty) {
        filtered.add(MenuModel(
          menuCD: item.menuCD,
          menuName: item.menuName,
          mobileIcon: item.mobileIcon,
          routeurl: item.routeurl,
          parentId: item.parentId,
          expandable: item.expandable,
          children: filteredChildren,
        ));
      }
    }

    return filtered;
  }

  List<MenuModel> buildMenuHierarchy(List<MenuModel> flatMenu) {
    Map<String, MenuModel> menuMap = {for (var m in flatMenu) m.menuCD: m};
    List<MenuModel> rootMenus = [];

    for (var menu in flatMenu) {
      if (menu.parentId.isEmpty || menu.parentId == '000') {
        rootMenus.add(menu);
      } else {
        final parent = menuMap[menu.parentId];
        if (parent != null) {
          parent.children.add(menu); // safe now
        }
      }
    }

    return rootMenus;
  }

  @override
  Widget build(BuildContext context) {
    final List<MenuModel> menuTree = this.menuTree;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back arrow
        backgroundColor: const Color(0xFF136FF8),
        title: Row(
          children: [
            const SizedBox(width: 10),
            // Container(
            //   width: 50, // Set width
            //   height: 50, // Set height
            //   decoration: const BoxDecoration(
            //     color: Colors.white, // ✅ Background circle color
            //     shape: BoxShape.circle,
            //   ),
            //   alignment: Alignment.center,
            //   child: GestureDetector(
            //     onTap: () {
            //       Navigator.push(
            //         context,
            //         CupertinoPageRoute(
            //           builder: (context) => const Profile(),
            //         ),
            //       );
            //     },
            //     child: !globals.userName.isNotEmpty
            //         ? Text(
            //             function.getInitials(globals.userName),
            //             style: const TextStyle(
            //               fontWeight: FontWeight.bold,
            //               fontSize: 16,
            //               color: Colors.black,
            //             ),
            //           )
            //         : ClipOval(
            //             child: Image.network(
            //               globals.profilephoto,
            //               width: 48,
            //               height: 48,
            //               fit: BoxFit.cover,
            //             ),
            //           ),
            //   ),
            // ),
            // const SizedBox(width: 10),
            // Text(
            //   globals.userName,
            //   style: const TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // center horizontally
                children: [
                  Image.asset(
                    'assets/images/hr.png',
                    width: 80,
                    height: 50,
                  ),
                  //const Icon(FontAwesomeIcons.userTie, size: 24,color: Colors.white),
                  //const SizedBox(width: 8), // spacing between icon & text
                  const Text(
                    "HR Management System",
                    style: TextStyle(
                      fontSize: 20, // set font size
                      fontWeight: FontWeight.bold, // bold text
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            //const Spacer(),
            // Container(
            //   decoration: BoxDecoration(
            //     color: const Color.fromARGB(131, 190, 185, 185),
            //     borderRadius: BorderRadius.circular(
            //         8), // optional, for slightly rounded corners
            //   ),
            //   child: IconButton(
            //     icon: const Icon(Icons.power_settings_new, color: Colors.white),
            //     onPressed: () {
            //       CommonFunction cf = CommonFunction();
            //       cf.clearGlobals();
            //       Navigator.of(context).push(
            //         CupertinoPageRoute(
            //           builder: (_) => const LoginPage(),
            //         ),
            //       );
            //     },
            //   ),
            // )
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF136FF8),
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              //width: 300,  // 👈 adjust width
              height: 40,
              child: TextField(
                onChanged: _filterMenu, // 🔹 filter as user types
                decoration: InputDecoration(
                  hintText: 'Search your app...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.all(8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          // const Padding(
          //   padding: EdgeInsets.all(10),
          //   child: Row(
          //     mainAxisAlignment:
          //         MainAxisAlignment.center, // center horizontally
          //     children: [
          //       Icon(FontAwesomeIcons.userTie, size: 24),
          //       SizedBox(width: 8), // spacing between icon & text
          //       Text(
          //         "HR Management System",
          //         style: TextStyle(
          //           fontSize: 18, // set font size
          //           fontWeight: FontWeight.bold, // bold text
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Card(
              elevation: 0,
              color: const Color.fromARGB(255, 231, 231, 231),
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: menuTree.length,
                  itemBuilder: (context, index) {
                    final item = menuTree[index];
                    if (item.expandable) {
                      return _ExpandableSection(
                        title: item.menuName,
                        leadingIcon: getIconFromName(item.mobileIcon),
                        children: item.children.map((submenu) {
                          return ExpandableChild(
                              submenu.menuName, submenu.routeurl);
                        }).toList(),
                      );
                    } else {
                      return _MenuTile(
                        icon: getIconFromName(item.mobileIcon),
                        title: item.menuName,
                        trailing: null,
                        
                        // trailing: item.menuCD != null
                        //     ? Badge(
                        //         label: Text(item['badge']),
                        //         child: const SizedBox(width: 1, height: 1),
                        //       )
                        //     : null,
                        routename: item.menuName,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabindex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            tabindex = index;
          });
          if (index == 0) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ModuleList()));
          }
          if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const Profile()));
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.bars), label: 'Module'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.user), label: 'Profile'),
        ],
      ),
    );
  }

  Widget menuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: () {},
    );
  }

  Widget menuItemWithBadge(IconData icon, String title, int badgeCount) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Row(
        children: [
          Text(title),
          const SizedBox(width: 8),
          if (badgeCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: () {},
    );
  }

  Widget subMenuItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 4, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title),
      ),
    );
  }
}
