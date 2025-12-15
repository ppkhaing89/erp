class SystemModel {
  final String systemCD;
  final String systemName;
  final String mobileIcon;

  SystemModel(
      {required this.systemCD,
      required this.systemName,
      required this.mobileIcon});

  factory SystemModel.fromJson(Map<String, dynamic> json) {
    return SystemModel(
      systemCD: json['SystemCD'],
      systemName: json['SystemName'],
      mobileIcon: json['MobileIcon'],
    );
  }
}
