import 'package:erp/common/api.dart';
import 'package:erp/customWidgets/erpbgicon.dart';
import 'package:flutter/cupertino.dart';

class YearSeachList extends StatefulWidget {
  final int from;
  final int to;
  const YearSeachList({super.key, required this.from, required this.to});

  @override
  State<YearSeachList> createState() => _YearSeachListState();
}

class _YearSeachListState extends State<YearSeachList> {
  Api api = Api();
  List<String> dataList = [];
  bool isLoading = false;
  String selectedYear = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    getYear();
  }

  void getYear() {
    for (int year = widget.from; year >= widget.to; year--) {
      dataList.add(year.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CupertinoActivityIndicator())
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
                  middle: const Text('Partner List'),
                  trailing: GestureDetector(
                    onTap: () {
                      Navigator.pop(context, selectedYear);
                    },
                    child: const Text(
                      'Select',
                      style: TextStyle(color: CupertinoColors.activeBlue),
                    ),
                  ),
                ),
                child: SafeArea(
                    // Use SafeArea to avoid overlap
                    child: SingleChildScrollView(
                        child: Column(
                  children: [
                    CupertinoListSection.insetGrouped(
                      header: Column(
                        children: [
                          CupertinoSearchTextField(
                            // Add the search bar here
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                          const SizedBox(
                              height:
                                  10), // Add spacing between search bar and list
                        ],
                      ),
                      children: dataList
                          .where((item) =>
                              item.contains(searchQuery.toLowerCase()))
                          .take(30)
                          .map((item) {
                        TextStyle textStyle = const TextStyle(
                          fontSize: 12, // Change this to the desired font size
                          color: CupertinoColors
                              .black, // Change this to the desired text color
                        );
                        return CupertinoListTile.notched(
                          leading: erpBGIcon(
                              icon: const Icon(
                                CupertinoIcons.calendar,
                                color: CupertinoColors.white,
                              ),
                              backgroundcolor: CupertinoColors.systemRed),
                          title: Text(
                            item,
                            style: textStyle,
                          ),
                          trailing: item == selectedYear
                              ? const Icon(CupertinoIcons.check_mark,
                                  color: CupertinoColors.activeBlue)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedYear = item;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                )))));
  }
}
