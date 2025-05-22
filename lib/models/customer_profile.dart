class CustomerProfile {
  final String? name;
  final String? phone;
  final String? address;
  final String? profileImageUrl;

  CustomerProfile({this.name, this.phone, this.address, this.profileImageUrl});

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'address': address,
        'profile_image_url': profileImageUrl,
      };
}
