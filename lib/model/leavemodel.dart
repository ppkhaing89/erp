class LeaveModel {
  final String title;
  final String count;
  final String total;
  

  LeaveModel({
    required this.title,
    required this.count,
    required this.total,
   
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      title: json['title'],
      count: json['count'].toString().padLeft(2, '0'),
      total: json['total'].toString().padLeft(2, '0'),
    );
  }
}

  class LeaveTakenModel {
  final String name;
  final String leavetype;
  final String leavetime;
  final String profilephoto;

   LeaveTakenModel({
    required this.name,
    required this.leavetype,
    required this.leavetime,
    required this.profilephoto,
  });

  factory LeaveTakenModel.fromJson(Map<String, dynamic> json) {
    return LeaveTakenModel(
      name: json['name'],
      leavetype: json['leavetype'],
      leavetime: json['leavetime'],
      profilephoto: json['profilephoto'],
    );
  }
}
