import 'package:erp/common/function.dart';
import 'package:erp/model/global.dart';
import 'package:erp/views/dss/meeting/meetinglist.dart';
import 'package:erp/views/home/modulelist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:erp/views/home/login.dart';

class DSSMenuWidget extends StatefulWidget {
  final PageList currentPage;

  const DSSMenuWidget({super.key, required this.currentPage});

  @override
  State<DSSMenuWidget> createState() => _DSSMenuWidgetState();
}

class _DSSMenuWidgetState extends State<DSSMenuWidget> {
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  void initState() {
    super.initState();
    // Set the selectedIndex initially
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
        backdrop: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 22, 196, 240),
                Colors.lightGreen,
              ],
            ),
          ),
        ),
        controller: _advancedDrawerController,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        animateChildDecoration: true,
        rtlOpening: false,
        // openScale: 1.0,
        disabledGestures: false,
        childDecoration: const BoxDecoration(
          // NOTICE: Uncomment if you want to add shadow behind the page.
          // Keep in mind that it may cause animation jerks.
          // boxShadow: <BoxShadow>[
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 0.0,
          //   ),
          // ],
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        drawer: SafeArea(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 128.0,
                  height: 128.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/hr.png',
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const DSSMenuWidget(
                              currentPage: PageList.meeting,
                            )));
                  },
                  leading: const Icon(Icons.alarm),
                  title: const Text('Meeting'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ModuleList()));
                  },
                  leading: const Icon(CupertinoIcons.cube),
                  title: const Text('Module Selector'),
                ),
                ListTile(
                  onTap: () {
                    CommonFunction cf = CommonFunction();
                    cf.clearGlobals();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()));
                  },
                  leading: const Icon(CupertinoIcons.lock_shield),
                  title: const Text('Logout'),
                ),
                const Spacer(),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: const Text('Terms of Service | Privacy Policy'),
                  ),
                ),
              ],
            ),
          ),
        ),
        child: CupertinoApp(
            home: widget.currentPage == PageList.meeting
                ? CupertinoPageScaffold(
                    resizeToAvoidBottomInset: false,
                    navigationBar: CupertinoNavigationBar(
                      leading: IconButton(
                        onPressed: _handleMenuButtonPressed,
                        icon: ValueListenableBuilder<AdvancedDrawerValue>(
                          valueListenable: _advancedDrawerController,
                          builder: (_, value, __) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                value.visible ? Icons.clear : Icons.menu,
                                key: ValueKey<bool>(value.visible),
                              ),
                            );
                          },
                        ),
                      ),
                      middle: const Text('D-Link Sales System'),
                    ),
                    child: SafeArea(
                        // Use SafeArea to avoid overlap
                        child: widget.currentPage == PageList.meeting
                            ? const MeetingList()
                            : const Center(child: Text(''))))
                : CupertinoTabScaffold(
                    tabBar: widget.currentPage == PageList.meeting
                        ? CupertinoTabBar(
                            // A try for making invisible bar.
                            items: const <BottomNavigationBarItem>[
                              BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.transparent,
                                  ),
                                  backgroundColor: Colors.transparent),
                              BottomNavigationBarItem(
                                  icon: Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.transparent,
                                  ),
                                  backgroundColor: Colors.transparent)
                            ],
                            backgroundColor:
                                Colors.transparent,
                            inactiveColor: Colors.transparent,
                            activeColor: Colors.transparent,
                            border: const Border(
                              top: BorderSide(
                                color: Colors.transparent,
                                width: 0.0, // One physical pixel.
                                style: BorderStyle.none,
                              ),
                            ),
                          )
                        : CupertinoTabBar(
                            items: const <BottomNavigationBarItem>[
                              BottomNavigationBarItem(
                                icon: Icon(CupertinoIcons.calendar),
                                label: 'Meeting List',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(CupertinoIcons.calendar_badge_plus),
                                label: 'Meeting Entry',
                              ),
                            ],
                          ),
                    tabBuilder: (BuildContext context, int index) {
                      return CupertinoTabView(builder: (BuildContext context) {
                        return CupertinoPageScaffold(
                            resizeToAvoidBottomInset: false,
                            navigationBar: CupertinoNavigationBar(
                              leading: IconButton(
                                onPressed: _handleMenuButtonPressed,
                                icon:
                                    ValueListenableBuilder<AdvancedDrawerValue>(
                                  valueListenable: _advancedDrawerController,
                                  builder: (_, value, __) {
                                    return AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      child: Icon(
                                        value.visible
                                            ? Icons.clear
                                            : Icons.menu,
                                        key: ValueKey<bool>(value.visible),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              middle: const Text('D-Link Sales System'),
                            ),
                            child: SafeArea(
                                // Use SafeArea to avoid overlap
                                child: widget.currentPage == PageList.meeting
                                    ? const MeetingList()
                                    : const Center(child: Text(''))));
                      });
                    },
                  )));
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}
