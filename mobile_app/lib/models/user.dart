class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.role,
    this.historyCount = 0,
    this.bookmarkCount = 0,
  });

  final int id;
  final String email;
  final String fullName;
  final String avatarUrl;
  final String role;
  final int historyCount;
  final int bookmarkCount;

  bool get isAdmin => role == 'ROLE_ADMIN';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ??
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
      role: json['role'] as String? ?? 'ROLE_USER',
      historyCount: (json['historyCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'role': role,
      'historyCount': historyCount,
      'bookmarkCount': bookmarkCount,
    };
  }
}
