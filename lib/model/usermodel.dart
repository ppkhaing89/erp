class UserModel {
  final String userCD;
  final String name;
  final String dOB;
  final String countryCD;
  final String countryName;
  final String email;
  final String officePh;
  final String mobilePh;
  final String jobTitle;
  final String department;
  final String manager;
  final String joinedDate;
  final String company;
  final String profilephoto;

  UserModel({
    required this.userCD,
    required this.name,
    required this.dOB,
    required this.countryCD,
    required this.countryName,
    required this.email,
    required this.officePh,
    required this.mobilePh,
    required this.jobTitle,
    required this.department,
    required this.manager,
    required this.joinedDate,
    required this.company,
    required this.profilephoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userCD: json['UserCD'],
      name: json['Name'],
      dOB: json['DOB'],
      countryCD: json['CountryCD'],
      countryName: json['CountryName'],
      email: json['Email'],
      officePh: json['ExtensionNo_Display'],
      mobilePh: json['PhoneNo_Display'],
      jobTitle: json['JobTitleName'],
      department: json['DepartmentName'],
      manager: json['ManagerName'],
      joinedDate: json['JoinedDate'],
      company : json['ComName'],
      profilephoto: json['ProfilePhoto'],
    );
  }
}
