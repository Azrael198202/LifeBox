class AuthStore {
  String? _token;

  String? get token => _token;

  void setToken(String token) {
    _token = token;
  }

  void clear() {
    _token = null;
  }
}
