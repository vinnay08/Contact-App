class Contact {
  int? id;
  String firstName;
  String lastName;
  String phone;
  String email;
  String company;
  String state;
  String city;
  String street;
  String dppath;

  Contact({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.company = '',
    this.state = '',
    this.city = '',
    this.street = '',
    this.dppath = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'company': company,
      'state': state,
      'city': city,
      'street': street,
      'dppath': dppath,
    };
  }

  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      email: map['email'],
      company: map['company'],
      state: map['state'],
      city: map['city'],
      street: map['street'],
      dppath: map['dppath'],
    );
  }
}
