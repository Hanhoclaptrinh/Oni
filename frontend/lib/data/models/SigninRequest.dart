// payload client gửi lên cho auth sign in
class SigninRequest {
  final String email;
  final String password;

  SigninRequest({required this.email, required this.password});

  factory SigninRequest.fromJson(Map<String, dynamic> json) {
    return SigninRequest(email: json['email'], password: json['password']);
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
