import 'dart:convert';

import 'package:erp/common/api.dart';
import 'package:erp/customWidgets/erpbgicon.dart';
import 'package:erp/model/partnermodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PartnerSeachList extends StatefulWidget {
  final String countryCD;
  final TextEditingController controller;
  const PartnerSeachList(
      {super.key, required this.countryCD, required this.controller});

  @override
  State<PartnerSeachList> createState() => _PartnerSeachListState();
}

class _PartnerSeachListState extends State<PartnerSeachList> {
  Api api = Api();
  List<PartnerModel> dataList = [];
  bool isLoading = true;
  String? selectedPartnerCD;
  String selectedPartner = "";
  String searchQuery = '';

  Future<void> getPartner() async {
    var obj = <String, String>{
      'CountryCD': widget.countryCD, //globals.userCD,
    };
    String res = await api.apiCall('DSSPartnerApi/GetPartnerAutocomplete', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        dataList = jsonData
            .map((item) => PartnerModel.fromJson(item))
            .toList(); // Parse the JSON data into model objects

        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPartner();
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
                      widget.controller.text = selectedPartner;
                      Navigator.pop(context);
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
                          .where((partner) => partner.partnerName
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                          .take(30)
                          .map((partner) {
                        TextStyle textStyle = const TextStyle(
                          fontSize: 12, // Change this to the desired font size
                          color: Colors
                              .black, // Change this to the desired text color
                        );
                        return CupertinoListTile.notched(
                          leading: erpBGIcon(
                              icon: const Icon(
                                CupertinoIcons.building_2_fill,
                                color: CupertinoColors.white,
                              ),
                              backgroundcolor: CupertinoColors.black),
                          title: Text(
                            partner.partnerName,
                            style: textStyle,
                          ),
                          subtitle: Text(
                            partner.partnerCD,
                            style: textStyle,
                          ),
                          trailing: partner.partnerCD == selectedPartnerCD
                              ? const Icon(CupertinoIcons.check_mark,
                                  color: CupertinoColors.activeBlue)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedPartnerCD = partner.partnerCD;
                              selectedPartner = partner.partnerName;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                )))));
  }
}
