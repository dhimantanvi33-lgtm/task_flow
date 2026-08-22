enum MemberRole { orgAdmin, member }

extension MemberRoleX on MemberRole {
  String get label => this == MemberRole.orgAdmin ? 'Admin' : 'Member';
  bool get isAdmin => this == MemberRole.orgAdmin;
  String get wire => this == MemberRole.orgAdmin ? 'org_admin' : 'member';
  static MemberRole parse(String? raw) =>
      raw == 'org_admin' ? MemberRole.orgAdmin : MemberRole.member;
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final MemberRole role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = MemberRole.member,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    // Present when hydrated from a member/credential join; absent in `users`.
    role: MemberRoleX.parse(json['role'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.wire,
  };

  UserModel copyWith({MemberRole? role}) =>
      UserModel(id: id, name: name, email: email, role: role ?? this.role);

  static const sampleAdmin =
  UserModel(id: 'usr_ava', name: 'Ava Thompson', email: 'ava.admin@nimbusdigital.test', role: MemberRole.orgAdmin);

  static const orgMembers = [
    UserModel(id: 'usr_ava', name: 'Ava Thompson', email: 'ava.admin@nimbusdigital.test', role: MemberRole.orgAdmin),
    UserModel(id: 'usr_marcus', name: 'Marcus Reed', email: 'marcus.member@nimbusdigital.test'),
  ];
}