class PartnerModel {
  final String partnerCD;
  final String partnerName;

  PartnerModel({
    required this.partnerCD,
    required this.partnerName,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      partnerCD: json['PartnerCD'] ?? '',
      partnerName: json['PartnerName'] ?? '',
    );
  }
}
