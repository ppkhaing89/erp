import 'dart:convert';
import 'package:erp/common/api.dart';
import 'package:erp/common/message.dart';
import 'package:erp/customWidgets/erpbgicon.dart';
import 'package:erp/model/jdeinventorymodel.dart';
import 'package:erp/views/dss/seaching/itemsearchlist.dart';
import 'package:erp/views/dss/seaching/yearsearchlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:erp/model/global.dart' as globals;

class InquiryInventory extends StatefulWidget {
  const InquiryInventory({super.key});

  @override
  State<InquiryInventory> createState() => _InquiryInventoryState();
}

class _InquiryInventoryState extends State<InquiryInventory> {
  Api api = Api();
  Message msg = Message();
  bool isLoading = false;
  bool isDownloading = false;
  TextEditingController txtModelNo = TextEditingController();
  TextEditingController txtYear = TextEditingController();
  List<JDEInventoryModel> dataList = [];

  @override
  void initState() {
    super.initState();
    txtYear.text = DateTime.now().year.toString();
  }

  @override
  void dispose() {
    txtModelNo.dispose();
    txtYear.dispose();
    super.dispose();
  }

  void getInventoryInfo() async {
    isLoading = true;
    var obj = <String, String>{
      'ConsoleCD': 'DSS_JDEInventory_Import',
      'UserCD': globals.userCD,
    };

    String response =
        await api.apiCall('InquiryApi/JDEInvImportConsoleCheck', obj);
    dynamic jsonObject = jsonDecode(jsonDecode(response.toString()));
    if (jsonObject.length > 0) {
      if (jsonObject[0]['ConsoleStatus'] == '1') {
        if (mounted) {
          msg.showMessageDialog(context,
              'Downloading on-hand quantity data from HQ is currently in progress. Please try again in 1 or 2 minutes.');
        }
        setState(() {
          isDownloading = true;
          isLoading = false;
          txtModelNo.text = '';
        });
      } else {
        var obj = <String, String>{
          'ModelNo': txtModelNo.text,
          'Year': txtYear.text,
        };

        String response =
            await api.apiCall('InquiryApi/GetJDEInventoryData', obj);
        dynamic jsonData = jsonDecode(jsonDecode(response.toString()));

        if (jsonData.length > 0) {
          if (jsonData is List) {
            setState(() {
              isDownloading = false;
              isLoading = false;
              dataList = jsonData
                  .map((item) => JDEInventoryModel.fromJson(item))
                  .toList(); // Parse the JSON data into model objects
            });
          }
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void modelSearch() async {
    var selectedModelNo = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => const ItemSearchList(),
      ),
    );

    if (selectedModelNo != null && selectedModelNo != '') {
      setState(() {
        isLoading = true;
        txtModelNo.text = selectedModelNo; // Update the text
        getInventoryInfo();
      });
    }
  }

  void yearSearch() async {
    var selectedyear = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => YearSeachList(
          from: DateTime.now().year,
          to: 2015,
        ),
      ),
    );

    if (selectedyear != null && selectedyear != '') {
      setState(() {
        isLoading = true;
        txtYear.text = selectedyear; // Update the text
        getInventoryInfo();
      });
    }
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
                    middle: const Text('Inquiry Inventory')),
                child: SafeArea(
                    // Use SafeArea to avoid overlap
                    child: SingleChildScrollView(
                        child: Column(
                  children: [
                    searchWidget(),
                    isDownloading
                        ? const Text('')
                        : dataList.isEmpty
                            ? const Text('')
                            : Column(
                                children: [
                                  SizedBox(
                                    height: 650, // Set a fixed height
                                    child: PageView(
                                      children: [
                                        getQty(1),
                                        getQty(2),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                  ],
                )))));
  }

  Widget searchWidget() {
    TextStyle textStyle = const TextStyle(
      fontSize: 14, // Change this to the desired font size
      color: Colors.black, // Change this to the desired text color
    );
    return CupertinoListSection.insetGrouped(
      margin: const EdgeInsets.all(20),
      children: <Widget>[
        Image.asset(
          'assets/images/inquiryinv.jpg',
        ),
        CupertinoListTile.notched(
          leading: erpBGIcon(
              icon: const Icon(
                CupertinoIcons.cube,
                color: Colors.white,
              ),
              backgroundcolor: CupertinoColors.systemRed),
          title: Text(
            'Model No.',
            style: textStyle,
          ),
          additionalInfo: Text(
            txtModelNo.text,
            style: const TextStyle(fontSize: 14),
          ),
          trailing: const Icon(CupertinoIcons.right_chevron),
          onTap: () {
            modelSearch();
          },
        ),
        CupertinoListTile.notched(
          leading: erpBGIcon(
              icon: const Icon(
                CupertinoIcons.calendar,
                color: Colors.white,
              ),
              backgroundcolor: CupertinoColors.systemPink),
          title: Text(
            'Year',
            style: textStyle,
          ),
          additionalInfo: Text(
            txtYear.text,
            style: const TextStyle(fontSize: 14),
          ),
          trailing: const Icon(CupertinoIcons.right_chevron),
          onTap: () {
            yearSearch();
          },
        ),
      ],
    );
  }

  Widget buildQtySection(String header, Map<String, String> countryQty) {
    TextStyle titleStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black,
    );
    TextStyle trailingStyle = const TextStyle(
      fontSize: 14,
      color: CupertinoColors.systemGrey,
    );

    List<CupertinoListTile> tiles = [];

    // Add total first
    tiles.add(
      CupertinoListTile.notched(
        leading: const Icon(
          CupertinoIcons.globe,
          color: CupertinoColors.systemGreen,
        ),
        title: const Text('Total',
            style: TextStyle(fontSize: 14, color: Colors.black)),
        trailing: Text(countryQty['Total'] ?? '', style: trailingStyle),
      ),
    );

    // Add countries dynamically
    countryQty.forEach((country, qty) {
      if (country == 'Total') return; // skip total, already added

      tiles.add(
        CupertinoListTile.notched(
          leading: CountryFlag.fromCountryCode(
            country,
            borderRadius: 8,
          ),
          title: Text(
            getCountryName(country),
            style: titleStyle,
          ),
          trailing: Text(qty, style: trailingStyle),
        ),
      );
    });

    return CupertinoListSection.insetGrouped(
      header: Text(header, style: titleStyle),
      children: tiles,
    );
  }

// Helper to map country codes to full names
  String getCountryName(String code) {
    switch (code) {
      case 'SG':
        return 'Singapore';
      case 'ID':
        return 'Indonesia';
      case 'MY':
        return 'Malaysia';
      case 'PH':
        return 'Philippines';
      case 'TH':
        return 'Thailand';
      case 'VN':
        return 'Vietnam';
      case 'BN':
        return 'Brunei';
      case 'KH':
        return 'Cambodia';
      case 'MM':
        return 'Myanmar';
      case 'LA':
        return 'Laos';
      default:
        return code;
    }
  }

// Example usage
  Widget getQty(int type) {
    if (dataList.isEmpty) return const SizedBox.shrink();

    Map<String, String> qtyMap;
    String header;

    if (type == 1) {
      qtyMap = {
        'Total': dataList[0].ohqTotal,
        'SG': dataList[0].ohqSG,
        'ID': dataList[0].ohqID,
        'MY': dataList[0].ohqMY,
        'PH': dataList[0].ohqPH,
        'TH': dataList[0].ohqTH,
        'VN': dataList[0].ohqVN,
        'BN': dataList[0].ohqBN,
        'KH': dataList[0].ohqKH,
        'MM': dataList[0].ohqMM,
        'LA': dataList[0].ohqLA,
      };
      header = 'On Hand Quantity';
    } else {
      qtyMap = {
        'Total': dataList[0].dohqTotal,
        'SG': dataList[0].dohqSG,
        'ID': dataList[0].dohqID,
        'MY': dataList[0].dohqMY,
        'PH': dataList[0].dohqPH,
        'TH': dataList[0].dohqTH,
        'VN': dataList[0].dohqVN,
        'BN': dataList[0].dohqBN,
        'KH': dataList[0].dohqKH,
        'MM': dataList[0].dohqMM,
        'LA': dataList[0].dohqLA,
      };
      header = 'Disty On Hand Quantity';
    }

    return buildQtySection(header, qtyMap);
  }
}
