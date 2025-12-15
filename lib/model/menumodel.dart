class MenuModel {
  final String menuCD;
  final String menuName;
  final String mobileIcon;
  final String routeurl;
  final String parentId;
  final bool expandable;
  List<MenuModel> children;

  MenuModel({
    required this.menuCD,
    required this.menuName,
    required this.mobileIcon,
    required this.routeurl,
    required this.parentId,
    required this.expandable,
    List<MenuModel>? children, // optional param
  }) : children = children ?? []; // default to empty list

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menuCD: json['MenuCD'],
      menuName: json['MenuName'],
      mobileIcon: json['IconName'],
      routeurl: json['URL'],
      parentId: json['ParentMenuCD'],
      expandable: json['Expandable'] ?? false,
      children: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuCD': menuCD,
      'menuName': menuName,
      'mobileIcon': mobileIcon,
      'routeurl': routeurl,
      'parentId': parentId,
      'children': children.map((c) => c.toMap()).toList(),
    };
  }
}
