class Credentials {
  String email;
  String password;
  String uid;

  Credentials({this.email, this.password, this.uid});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'uid': uid,
    };
  }
}
