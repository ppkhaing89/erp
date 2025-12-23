class UserModel {
  final String? userCD;
  final String? name;
  final String? dOB;
  final String? countryCD;
  final String? countryName;
  final String? email;
  final String? officePh;
  final String? mobilePh;
  final String? jobTitle;
  final String? department;
  final String? manager;
  final String? joinedDate;
  final String? company;
  final String? profilephoto;

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
      userCD: json['UserCD']?.toString(),
      name: json['Name']?.toString(),
      dOB: json['DOB']?.toString(),
      countryCD: json['CountryCD']?.toString(),
      countryName: json['CountryName']?.toString(),
      email: json['Email']?.toString(),
      officePh: json['ExtensionNo_Display']?.toString(),
      mobilePh: json['PhoneNo_Display']?.toString(),
      jobTitle: json['JobTitleName']?.toString(),
      department: json['DepartmentName']?.toString(),
      manager: json['ManagerName']?.toString(),
      joinedDate: json['JoinedDate']?.toString(),
      company : json['ComName']?.toString(),
      profilephoto: json['ProfilePhoto']?.toString(),
    );
  }
}
