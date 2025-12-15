class JDEInventoryModel {
  final String ohqTotal;
  final String ohqBN;
  final String ohqID;
  final String ohqKH;
  final String ohqMM;
  final String ohqMY;
  final String ohqPH;
  final String ohqSG;
  final String ohqTH;
  final String ohqVN;
  final String ohqLA;
  final String dohqTotal;
  final String dohqBN;
  final String dohqID;
  final String dohqKH;
  final String dohqMM;
  final String dohqMY;
  final String dohqPH;
  final String dohqSG;
  final String dohqTH;
  final String dohqVN;
  final String dohqLA;

  JDEInventoryModel(
      {required this.ohqTotal,
      required this.ohqBN,
      required this.ohqID,
      required this.ohqKH,
      required this.ohqMM,
      required this.ohqMY,
      required this.ohqPH,
      required this.ohqSG,
      required this.ohqTH,
      required this.ohqVN,
      required this.ohqLA,
      required this.dohqTotal,
      required this.dohqBN,
      required this.dohqID,
      required this.dohqKH,
      required this.dohqMM,
      required this.dohqMY,
      required this.dohqPH,
      required this.dohqSG,
      required this.dohqTH,
      required this.dohqVN,
      required this.dohqLA});

  factory JDEInventoryModel.fromJson(Map<String, dynamic> json) {
    return JDEInventoryModel(
      ohqTotal: json['Total_OHQ'] ?? '',
      ohqBN: json['BN_OHQ'] ?? '',
      ohqID: json['ID_OHQ'] ?? '',
      ohqKH: json['KH_OHQ'] ?? '',
      ohqMM: json['MM_OHQ'] ?? '',
      ohqMY: json['MY_OHQ'] ?? '',
      ohqPH: json['PH_OHQ'] ?? '',
      ohqSG: json['SG_OHQ'] ?? '',
      ohqTH: json['TH_OHQ'] ?? '',
      ohqVN: json['VN_OHQ'] ?? '',
      ohqLA: json['LA_OHQ'] ?? '',
      dohqTotal: json['Total_DOHQ'] ?? '',
      dohqBN: json['BN_DOHQ'] ?? '',
      dohqID: json['ID_DOHQ'] ?? '',
      dohqKH: json['KH_DOHQ'] ?? '',
      dohqMM: json['MM_DOHQ'] ?? '',
      dohqMY: json['MY_DOHQ'] ?? '',
      dohqPH: json['PH_DOHQ'] ?? '',
      dohqSG: json['SG_DOHQ'] ?? '',
      dohqTH: json['TH_DOHQ'] ?? '',
      dohqVN: json['VN_DOHQ'] ?? '',
      dohqLA: json['LA_DOHQ'] ?? '',
    );
  }
}
