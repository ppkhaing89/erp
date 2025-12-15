import 'dart:convert';

import 'package:erp/common/api.dart';
import 'package:erp/customWidgets/erpbgicon.dart';
import 'package:erp/model/itemmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemSearchList extends StatefulWidget {
  const ItemSearchList({super.key});

  @override
  State<ItemSearchList> createState() => _ItemSearchListState();
}

class _ItemSearchListState extends State<ItemSearchList> {
  Api api = Api();
  List<ItemModel> dataList = [];
  bool isLoading = true;
  String selectedModelNo = "";
  String searchQuery = '';

  Future<void> getItem() async {
    var obj = <String, String>{
      'ModelNo': '',
    };
    String res = await api.apiCall('DSSItemApi/GetItem', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        dataList = jsonData
            .map((item) => ItemModel.fromJson(item))
            .toList(); // Parse the JSON data into model objects

        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getItem();
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
                  middle: const Text('Model List'),
                  trailing: GestureDetector(
                    onTap: () {
                      Navigator.pop(context, selectedModelNo);
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
                          .where((item) => item.modelNo
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                          .take(30)
                          .map((item) {
                        TextStyle textStyle = const TextStyle(
                          fontSize: 12, // Change this to the desired font size
                          color: Colors
                              .black, // Change this to the desired text color
                        );
                        return CupertinoListTile.notched(
                          leading: erpBGIcon(
                              icon: const Icon(
                                CupertinoIcons.cube,
                                color: CupertinoColors.white,
                              ),
                              backgroundcolor: Colors.red),
                          title: Text(
                            item.modelNo,
                            style: textStyle,
                          ),
                          subtitle: Text(
                            item.modelDescription,
                            style: textStyle,
                          ),
                          trailing: item.modelNo == selectedModelNo
                              ? const Icon(CupertinoIcons.check_mark,
                                  color: CupertinoColors.activeBlue)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedModelNo = item.modelNo;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                )))));
  }
}
