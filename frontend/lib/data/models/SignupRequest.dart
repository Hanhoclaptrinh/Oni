// payload client gửi lên cho auth sign up
class SignupRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  SignupRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) {
    return SignupRequest(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  // chuyển thành json để gửi lên server
  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "email": email,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
    };
  }
}
