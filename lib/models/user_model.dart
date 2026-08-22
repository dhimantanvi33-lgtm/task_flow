enum MemberRole { orgAdmin, member }

extension MemberRoleX on MemberRole {
  String get label => this == MemberRole.orgAdmin ? 'Admin' : 'Member';
  bool get isAdmin => this == MemberRole.orgAdmin;
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final MemberRole role;

  const UserModel({required this.id, required this.name, required this.email, this.role = MemberRole.member});

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  static const sampleAdmin = UserModel(id: 'u1', name: 'Priya Sharma', email: 'priya@acme.test', role: MemberRole.orgAdmin);

  static const orgMembers = [
    UserModel(id: 'u1', name: 'Priya Sharma', email: 'priya@acme.test', role: MemberRole.orgAdmin),
    UserModel(id: 'u2', name: 'Rahul Verma', email: 'rahul@acme.test'),
    UserModel(id: 'u3', name: 'Meera Nair', email: 'meera@acme.test'),
  ];
}
