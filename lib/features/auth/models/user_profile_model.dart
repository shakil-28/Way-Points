/// Driver profile and authentication metadata model
class UserProfileModel {
  final String uid;
  final String email;
  final String name;
  final String nickname;
  final String avatarUrl;
  final String emergencyContact;
  final bool isLoggedIn;
  final bool isProfileComplete;

  const UserProfileModel({
    this.uid = '',
    this.email = '',
    this.name = '',
    this.nickname = '',
    this.avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    this.emergencyContact = '',
    this.isLoggedIn = false,
    this.isProfileComplete = false,
  });

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? nickname,
    String? avatarUrl,
    String? emergencyContact,
    bool? isLoggedIn,
    bool? isProfileComplete,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
