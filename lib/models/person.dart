class Person {
  String? id;
  String? imageProfile;
  String? name;
  String? email;
  int? age;

  Person({this.id, this.imageProfile, this.email, this.name, this.age});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'imageProfile': imageProfile,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      email: json['email'],
      imageProfile: json['imageProfile'],
    );
  }
}
