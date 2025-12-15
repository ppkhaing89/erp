class ItemModel {
  final String modelNo;
  final String modelDescription;

  ItemModel({
    required this.modelNo,
    required this.modelDescription,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      modelNo: json['ModelNo'] ?? '',
      modelDescription: json['ModelDescription'] ?? '',
    );
  }
}
