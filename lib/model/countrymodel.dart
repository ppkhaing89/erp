class CountryModel {
  final String code;
  final String name;

  CountryModel({required this.code, required this.name});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['CountryCD'],
      name: json['CountryName'],
    );
  }
}
