class EmployeeModel {
  final String empId;
  final String empName;

  EmployeeModel({required this.empId, required this.empName});

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      empId: json['UserCD'],
      empName: json['Name'],
    );
  }
}
