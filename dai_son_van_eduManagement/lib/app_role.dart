enum AppRole { admin, teacher, guest }

extension AppRoleLabel on AppRole {
  String get label => switch (this) {
    AppRole.admin => 'Quản trị viên',
    AppRole.teacher => 'Giảng viên',
    AppRole.guest => 'Khách',
  };
}
