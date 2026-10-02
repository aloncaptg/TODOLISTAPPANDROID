import 'dart:convert';

/// Model pengguna untuk sesi autentikasi dan profil lokal
class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String title;
  final bool isGuest;
  final DateTime joinedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar = '👨‍💻',
    this.title = 'Productivity Master',
    this.isGuest = false,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? title,
    bool? isGuest,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      title: title ?? this.title,
      isGuest: isGuest ?? this.isGuest,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'title': title,
      'isGuest': isGuest,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] as String?) ?? 'user-default',
      name: (map['name'] as String?) ?? 'Guest User',
      email: (map['email'] as String?) ?? 'guest@tugasku.pro',
      avatar: (map['avatar'] as String?) ?? '👨‍💻',
      title: (map['title'] as String?) ?? 'Productivity Master',
      isGuest: (map['isGuest'] as bool?) ?? false,
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
