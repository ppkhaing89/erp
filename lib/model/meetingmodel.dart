class MeetingModel {
  final String meetingStatus;
  final String meetingCD;
  final String countryName;
  final String partnerName;
  final String startDate;
  final String endDate;
  final String meetingPurpose;
  final String fileType;
  final String fileName;
  final String filePath;

  MeetingModel({
    required this.meetingStatus,
    required this.meetingCD,
    required this.countryName,
    required this.partnerName,
    required this.startDate,
    required this.endDate,
    required this.meetingPurpose,
    required this.fileType,
    required this.fileName,
    required this.filePath,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
        meetingStatus: json['MeetingStatus'] ?? '',
        meetingCD: json['MeetingCD'] ?? '',
        countryName: json['CountryName'] ?? '',
        partnerName: json['PartnerName'] ?? '',
        startDate: json['StartDate'] ?? '',
        endDate: json['EndDate'] ?? '',
        meetingPurpose: json['MeetingPurpose'] ?? '',
        fileName: json['FileName'] ?? '',
        fileType: json['FileType'] ?? '',
        filePath: json['FilePath'] ?? '');
  }
}
